const express = require('express');
const { z } = require('zod');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const requireRole = require('../middlewares/requireRole');
const validateBody = require('../middlewares/validateBody');
const supabase = require('../config/supabase');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');
const { generateLinkCode, formatLinkCode } = require('../utils/linkCode');

// Solo estos campos se pueden cambiar. Cualquier otro (role, fleet_id...) se rechaza con 400.
const updateProfileSchema = z.strictObject({
  full_name: z
    .string()
    .trim()
    .min(2, 'El nombre debe tener al menos 2 caracteres')
    .max(100, 'El nombre es demasiado largo')
    .optional(),
  phone: z
    .string()
    .trim()
    .min(8, 'El teléfono debe tener al menos 8 dígitos')
    .max(20, 'El teléfono es demasiado largo')
    .nullable()
    .optional()
});
const truckSchema = z.strictObject({
  plate: z
    .string()
    .trim()
    .regex(/^[A-Za-z0-9-]{4,12}$/, 'Patente inválida (4 a 12 letras, números o guiones)')
    .transform((value) => value.toUpperCase()),
  height_meters: z
    .number('La altura debe ser un número')
    .min(1, 'La altura mínima es 1 m')
    .max(6, 'La altura máxima es 6 m'),
  weight_tons: z
    .number('El peso debe ser un número')
    .min(0.5, 'El peso mínimo es 0.5 t')
    .max(100, 'El peso máximo es 100 t')
});

// GET /api/v1/me -> Quién soy: lo consulta el front justo después del login
// para decidir a qué pantalla enviar al usuario (admin -> dashboard, driver -> su camión).
router.get('/', protect, requireRole(), async (req, res, next) => {
  try {
    const { profile } = req;

    const data = {
      id: profile.id,
      email: req.user.email,
      full_name: profile.full_name,
      role: profile.role,
      fleet_id: profile.fleet_id,
      fleet: null
    };

    if (profile.fleet_id) {
      const { data: fleet, error } = await supabase
        .from('fleets')
        .select('id, name, plan_status')
        .eq('id', profile.fleet_id)
        .maybeSingle();

      if (error) {
        return next(new AppError('Error al consultar la flota', 500, 'ERR_FLEET_LOOKUP'));
      }

      if (fleet) {
        // Solo el jefe ve el estado del plan; el conductor solo ve a qué flota pertenece.
        data.fleet =
          profile.role === 'admin' ? fleet : { id: fleet.id, name: fleet.name };
      }
    }

    // El conductor recibe su camión (el front necesita el truck_id real).
    if (profile.role === 'driver') {
      const { data: trucks, error } = await supabase
        .from('trucks')
        .select('id, plate, height_meters, weight_tons, fleet_id')
        .eq('driver_id', profile.id);

      if (error) {
        return next(new AppError('Error al consultar el camión del conductor', 500, 'ERR_TRUCK_LOOKUP'));
      }

      data.trucks = trucks || [];
    }

    res.status(200).json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/me -> El usuario edita sus propios datos (solo el nombre).
router.patch('/', protect, requireRole(), validateBody(updateProfileSchema), async (req, res, next) => {
  try {
    const updates = {};
    if (req.body.full_name !== undefined) updates.full_name = req.body.full_name;
    if (req.body.phone !== undefined) updates.phone = req.body.phone;

    const { data: updated, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', req.profile.id)
      .select('id, full_name, phone, role, fleet_id')
      .single();

    if (error) {
      return next(new AppError('No se pudo actualizar el perfil', 500, 'ERR_PROFILE_UPDATE'));
    }

    res.status(200).json({ status: 'success', data: updated });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/me/truck -> El conductor crea o actualiza SU camión (uno por conductor).
// driver_id y fleet_id los decide el servidor, nunca el cliente.
router.put('/truck', protect, requireRole('driver'), validateBody(truckSchema), async (req, res, next) => {
  try {
    const { profile } = req;
    const { plate, height_meters, weight_tons } = req.body;

    const { data: existing, error: lookupError } = await supabase
      .from('trucks')
      .select('id')
      .eq('driver_id', profile.id)
      .maybeSingle();

    if (lookupError) {
      return next(new AppError('Error al consultar el camión del conductor', 500, 'ERR_TRUCK_LOOKUP'));
    }

    const query = existing
      ? supabase
          .from('trucks')
          .update({ plate, height_meters, weight_tons })
          .eq('id', existing.id)
          .select('id, plate, height_meters, weight_tons, fleet_id')
          .single()
      : supabase
          .from('trucks')
          .insert({ driver_id: profile.id, fleet_id: profile.fleet_id, plate, height_meters, weight_tons })
          .select('id, plate, height_meters, weight_tons, fleet_id')
          .single();

    const { data: truck, error } = await query;

    if (error) {
      return next(new AppError('No se pudo guardar el camión', 500, 'ERR_TRUCK_SAVE'));
    }

    logger.info(`Camión ${truck.id} ${existing ? 'actualizado' : 'creado'} por conductor ${profile.id}`);

    res.status(existing ? 200 : 201).json({ status: 'success', data: truck });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/me/link-code -> El conductor genera su código de enlace para compartirlo
// con su jefe de flota. Dura unas horas y sirve una sola vez; generar uno nuevo anula el anterior.
router.post('/link-code', protect, requireRole('driver'), async (req, res, next) => {
  try {
    const { profile } = req;
    const ttlHours = Number(process.env.LINK_CODE_TTL_HOURS || 24);
    const expiresAt = new Date(Date.now() + ttlHours * 60 * 60 * 1000).toISOString();

    // Anula los códigos anteriores sin usar de este conductor
    const { error: deleteError } = await supabase
      .from('driver_link_codes')
      .delete()
      .eq('driver_id', profile.id)
      .is('used_at', null);

    if (deleteError) {
      return next(new AppError('No se pudo generar el código', 500, 'ERR_LINK_CODE_CREATE'));
    }

    // Reintenta si, por azar, el código ya existe
    for (let attempt = 0; attempt < 5; attempt++) {
      const code = generateLinkCode();

      const { error } = await supabase
        .from('driver_link_codes')
        .insert({ code, driver_id: profile.id, expires_at: expiresAt });

      if (!error) {
        return res.status(201).json({
          status: 'success',
          data: { code: formatLinkCode(code), expires_at: expiresAt }
        });
      }

      if (error.code !== '23505') {
        return next(new AppError('No se pudo generar el código', 500, 'ERR_LINK_CODE_CREATE'));
      }
    }

    next(new AppError('No se pudo generar un código único, intenta de nuevo', 500, 'ERR_LINK_CODE_CREATE'));
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/me/leave-fleet -> El conductor sale de la flota cuando quiera.
router.post('/leave-fleet', protect, requireRole('driver'), async (req, res, next) => {
  try {
    const { profile } = req;

    const { error: truckError } = await supabase
      .from('trucks')
      .update({ fleet_id: null })
      .eq('driver_id', profile.id);

    const { error: profileError } = await supabase
      .from('profiles')
      .update({ fleet_id: null })
      .eq('id', profile.id);

    if (truckError || profileError) {
      return next(new AppError('No se pudo salir de la flota', 500, 'ERR_LEAVE_FLEET'));
    }

    logger.info(`Conductor ${profile.id} salió de la flota ${profile.fleet_id}`);

    res.status(200).json({ status: 'success', message: 'Saliste de la flota' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
