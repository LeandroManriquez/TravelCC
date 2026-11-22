const express = require('express');
const { z } = require('zod');
const rateLimit = require('express-rate-limit');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const requireRole = require('../middlewares/requireRole');
const requireActiveFleetPlan = require('../middlewares/requireActiveFleetPlan');
const validateBody = require('../middlewares/validateBody');
const supabase = require('../config/supabase');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');
const { normalizeLinkCode } = require('../utils/linkCode');
const { extractLatLng } = require('../utils/geo');

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const linkSchema = z.strictObject({
  code: z.string().trim().min(6, 'Código inválido').max(20, 'Código inválido')
});

// Frena los intentos de adivinar códigos: por jefe de flota, no por IP.
const linkLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.user.id,
  message: {
    status: 'fail',
    error_code: 'ERR_SYS_RATE_LIMIT',
    message: 'Demasiados intentos de enlace. Intenta de nuevo más tarde.'
  }
});

const invalidCodeError = () =>
  new AppError('Código inválido, vencido o ya utilizado', 404, 'ERR_LINK_CODE_INVALID');

// POST /api/v1/fleet/link -> El jefe ingresa el código del conductor y lo enlaza a su flota.
router.post(
  '/link',
  protect,
  requireRole('admin'),
  requireActiveFleetPlan,
  linkLimiter,
  validateBody(linkSchema),
  async (req, res, next) => {
    try {
      const fleetId = req.profile.fleet_id;
      const code = normalizeLinkCode(req.body.code);

      // Reclama el código de forma atómica: si dos jefes lo usan a la vez, solo uno lo consigue.
      const { data: claimed, error: claimError } = await supabase
        .from('driver_link_codes')
        .update({ used_at: new Date().toISOString() })
        .eq('code', code)
        .is('used_at', null)
        .gt('expires_at', new Date().toISOString())
        .select('driver_id')
        .maybeSingle();

      if (claimError) {
        return next(new AppError('No se pudo validar el código', 500, 'ERR_LINK_CODE_LOOKUP'));
      }

      if (!claimed) return next(invalidCodeError());

      const { data: driver, error: driverError } = await supabase
        .from('profiles')
        .select('id, full_name, role, fleet_id')
        .eq('id', claimed.driver_id)
        .maybeSingle();

      if (driverError) {
        return next(new AppError('No se pudo consultar al conductor', 500, 'ERR_PROFILE_LOOKUP'));
      }

      if (!driver || driver.role !== 'driver') return next(invalidCodeError());

      // Un conductor que ya está en otra flota tiene que salir primero.
      if (driver.fleet_id && driver.fleet_id !== fleetId) {
        return next(
          new AppError(
            'Ese conductor ya pertenece a otra flota. Debe salir de ella antes de enlazarse',
            409,
            'ERR_DRIVER_IN_FLEET'
          )
        );
      }

      const { error: truckError } = await supabase
        .from('trucks')
        .update({ fleet_id: fleetId })
        .eq('driver_id', driver.id);

      const { error: profileError } = await supabase
        .from('profiles')
        .update({ fleet_id: fleetId })
        .eq('id', driver.id);

      if (truckError || profileError) {
        return next(new AppError('No se pudo enlazar al conductor', 500, 'ERR_LINK_DRIVER'));
      }

      logger.info(`Conductor ${driver.id} enlazado a la flota ${fleetId} por ${req.profile.id}`);

      res.status(200).json({
        status: 'success',
        message: `${driver.full_name} fue enlazado a tu flota`,
        data: { driver: { id: driver.id, full_name: driver.full_name } }
      });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/fleet/trucks -> Camiones de la flota con conductor y última posición,
// más un resumen para el dashboard. Se puede consultar cada pocos segundos.
router.get('/trucks', protect, requireRole('admin'), requireActiveFleetPlan, async (req, res, next) => {
  try {
    const fleetId = req.profile.fleet_id;
    const activeWindowMs = Number(process.env.ACTIVE_WINDOW_MINUTES || 5) * 60 * 1000;

    const { data: trucks, error: trucksError } = await supabase
      .from('trucks')
      .select('id, plate, driver_id, height_meters, weight_tons')
      .eq('fleet_id', fleetId);

    if (trucksError) {
      return next(new AppError('Error al consultar los camiones de la flota', 500, 'ERR_TRUCK_LOOKUP'));
    }

    const fleetTrucks = trucks || [];
    const driverIds = [...new Set(fleetTrucks.map((t) => t.driver_id).filter(Boolean))];

    const driversById = new Map();
    if (driverIds.length > 0) {
      const { data: drivers, error: driversError } = await supabase
        .from('profiles')
        .select('id, full_name')
        .in('id', driverIds);

      if (driversError) {
        return next(new AppError('Error al consultar los conductores', 500, 'ERR_PROFILE_LOOKUP'));
      }

      (drivers || []).forEach((d) => driversById.set(d.id, d));
    }

    // Última posición de cada camión (una consulta por camión: suficiente para una flota pequeña).
    const items = await Promise.all(
      fleetTrucks.map(async (truck) => {
        const { data: point } = await supabase
          .from('gps_tracking')
          .select('location, speed_kmh, recorded_at')
          .eq('truck_id', truck.id)
          .order('recorded_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        const coords = point ? extractLatLng(point.location) : null;
        const driver = driversById.get(truck.driver_id);

        return {
          truck_id: truck.id,
          plate: truck.plate,
          height_meters: truck.height_meters,
          weight_tons: truck.weight_tons,
          driver: driver ? { id: driver.id, full_name: driver.full_name } : null,
          last_position:
            point && coords
              ? {
                  lat: coords.lat,
                  lng: coords.lng,
                  speed_kmh: point.speed_kmh,
                  recorded_at: point.recorded_at
                }
              : null
        };
      })
    );

    const now = Date.now();
    const activeTrucks = items.filter(
      (item) =>
        item.last_position &&
        now - new Date(item.last_position.recorded_at).getTime() <= activeWindowMs
    ).length;

    res.status(200).json({
      status: 'success',
      data: {
        summary: { total_trucks: items.length, active_trucks: activeTrucks },
        trucks: items
      }
    });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/v1/fleet/drivers/:driverId -> El jefe desvincula a un conductor de SU flota.
// No exige plan activo: siempre se puede dejar de ver a alguien.
router.delete('/drivers/:driverId', protect, requireRole('admin'), async (req, res, next) => {
  try {
    const { driverId } = req.params;
    const fleetId = req.profile.fleet_id;

    if (!UUID_REGEX.test(driverId)) {
      return next(new AppError('El id del conductor no es válido', 400, 'ERR_VALIDATION_FAILED'));
    }

    if (!fleetId) {
      return next(new AppError('Tu cuenta no tiene una flota asociada', 409, 'ERR_NO_FLEET'));
    }

    // Solo si ese conductor pertenece a la flota de quien pide (anti-IDOR)
    const { data: driver, error: lookupError } = await supabase
      .from('profiles')
      .select('id, fleet_id, role')
      .eq('id', driverId)
      .maybeSingle();

    if (lookupError) {
      return next(new AppError('No se pudo consultar al conductor', 500, 'ERR_PROFILE_LOOKUP'));
    }

    if (!driver || driver.role !== 'driver' || driver.fleet_id !== fleetId) {
      return next(new AppError('Conductor no encontrado en tu flota', 404, 'ERR_DRIVER_NOT_FOUND'));
    }

    const { error: truckError } = await supabase
      .from('trucks')
      .update({ fleet_id: null })
      .eq('driver_id', driverId)
      .eq('fleet_id', fleetId);

    const { error: profileError } = await supabase
      .from('profiles')
      .update({ fleet_id: null })
      .eq('id', driverId);

    if (truckError || profileError) {
      return next(new AppError('No se pudo desvincular al conductor', 500, 'ERR_UNLINK_DRIVER'));
    }

    logger.info(`Conductor ${driverId} desvinculado de la flota ${fleetId} por ${req.profile.id}`);

    res.status(200).json({ status: 'success', message: 'Conductor desvinculado de tu flota' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
