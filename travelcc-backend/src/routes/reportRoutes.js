const express = require('express');
const { z } = require('zod');
const router = express.Router();

const protect = require('../middlewares/authMiddleware');
const requireRole = require('../middlewares/requireRole');
const validateBody = require('../middlewares/validateBody');
const supabase = require('../config/supabase');
const { extractLatLng } = require('../utils/geo');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');

// Duración por defecto según el tipo de incidencia (en horas)
const EXPIRATION_HOURS = {
  heavy_traffic: 2,
  accident: 4,
  roadworks: 48,
  low_bridge: 24 * 365 // Estructura permanente (1 año)
};

const createReportSchema = z.strictObject({
  type: z.enum(['accident', 'roadworks', 'low_bridge', 'heavy_traffic']),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  description: z.string().trim().max(250).optional()
});

// POST /api/v1/reports -> Conductor reporta una incidencia en su posición actual
router.post(
  '/',
  protect,
  requireRole('driver'),
  validateBody(createReportSchema),
  async (req, res, next) => {
    try {
      const { type, lat, lng, description } = req.body;
      const hours = EXPIRATION_HOURS[type] || 4;
      const expiresAt = new Date(Date.now() + hours * 60 * 60 * 1000).toISOString();

      const { data: created, error } = await supabase
        .from('road_reports')
        .insert({
          driver_id: req.profile.id,
          type,
          description: description || null,
          location: {
            type: 'Point',
            coordinates: [lng, lat] // PostGIS: [longitud, latitud]
          },
          expires_at: expiresAt
        })
        .select('id, type, description, location, expires_at, created_at')
        .single();

      if (error) {
        return next(
          new AppError(`Error al guardar el reporte: ${error.message}`, 500, 'ERR_REPORT_INSERT')
        );
      }

      const coords = extractLatLng(created.location);
      logger.info(`Reporte [${type}] creado por conductor ${req.profile.id} en (${lat}, ${lng})`);

      res.status(201).json({
        status: 'success',
        message: 'Reporte vial registrado correctamente',
        data: {
          id: created.id,
          type: created.type,
          description: created.description,
          lat: coords ? coords.lat : lat,
          lng: coords ? coords.lng : lng,
          expires_at: created.expires_at,
          created_at: created.created_at
        }
      });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports -> Lista reportes activos para mostrarlos en el mapa
router.get('/', protect, requireRole('driver', 'admin'), async (req, res, next) => {
  try {
    const nowIso = new Date().toISOString();

    const { data, error } = await supabase
      .from('road_reports')
      .select('id, type, description, location, expires_at, created_at')
      .eq('is_active', true)
      .gt('expires_at', nowIso)
      .order('created_at', { ascending: false })
      .limit(100);

    if (error) {
      return next(
        new AppError(`Error al consultar reportes: ${error.message}`, 500, 'ERR_REPORTS_SELECT')
      );
    }

    const reports = (data || []).map((r) => {
      const coords = extractLatLng(r.location);
      return {
        id: r.id,
        type: r.type,
        description: r.description,
        lat: coords ? coords.lat : null,
        lng: coords ? coords.lng : null,
        expires_at: r.expires_at,
        created_at: r.created_at
      };
    });

    res.status(200).json({
      status: 'success',
      results: reports.length,
      data: reports
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;