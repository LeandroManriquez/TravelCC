const express = require('express');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const validateTelemetry = require('../middlewares/validateTelemetry');
const requireRole = require('../middlewares/requireRole');
const requireActiveFleetPlan = require('../middlewares/requireActiveFleetPlan');
const { getAuthorizedTrucks } = require('../utils/truckAccess');
const { extractLatLng } = require('../utils/geo');
const supabase = require('../config/supabase');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');

// POST /api/v1/telemetry -> Recibe los puntos GPS de los camiones
router.post('/', protect, requireRole('driver'), validateTelemetry, async (req, res, next) => {
  try {
    const rawData = req.body;
    const points = Array.isArray(rawData) ? rawData : [rawData];

    // //cambiar a futuro segun salida del front
    // Se asume que cada item trae: truck_id, lat, lng, speed_kmh y recorded_at
    const truckIds = [...new Set(points.map((p) => p.truck_id).filter(Boolean))];

    if (truckIds.length === 0) {
      return next(
        new AppError('El payload debe incluir truck_id válido', 400, 'ERR_MISSING_TRUCK_ID')
      );
    }

    const { allowedIds } = await getAuthorizedTrucks(req.profile, truckIds);

    const unauthorizedTruck = truckIds.find((id) => !allowedIds.has(id));
    if (unauthorizedTruck) {
      return next(
        new AppError(
          `No tienes permiso para enviar telemetría del camión ${unauthorizedTruck}`,
          403,
          'ERR_FORBIDDEN_TRUCK'
        )
      );
    }

    // Mapeo a columnas de gps_tracking
    // //cambiar a futuro segun salida del front
    const rowsToInsert = points.map((p) => ({
      truck_id: p.truck_id, // //cambiar a futuro segun salida del front
      location: {
        type: 'Point',
        coordinates: [p.lng, p.lat] // //cambiar a futuro segun salida del front (PostGIS: [longitud, latitud])
      },
      speed_kmh: p.speed_kmh ?? 0, // //cambiar a futuro segun salida del front
      recorded_at: p.recorded_at || new Date().toISOString() // //cambiar a futuro segun salida del front
    }));

    const { data: inserted, error: insertError } = await supabase
      .from('gps_tracking')
      .insert(rowsToInsert)
      .select('id');

    if (insertError) {
      return next(
        new AppError(`Error al guardar telemetría: ${insertError.message}`, 500, 'ERR_DB_INSERT')
      );
    }

    logger.info(
      `Telemetría almacenada en gps_tracking: ${rowsToInsert.length} registro(s) para usuario ${req.user.id}`
    );

    res.status(201).json({
      status: 'success',
      message: `Telemetría almacenada correctamente (${rowsToInsert.length} puntos)`,
      data: {
        received_points: rowsToInsert.length,
        inserted_count: inserted ? inserted.length : rowsToInsert.length
      }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/telemetry/:truckId/latest -> Última posición conocida del camión/conductor
router.get('/:truckId/latest', protect, requireRole('admin', 'driver'), requireActiveFleetPlan, async (req, res, next) => {
  try {
    const { truckId } = req.params;

    if (!truckId) {
      return next(new AppError('Debes indicar un truckId válido', 400, 'ERR_MISSING_TRUCK_ID'));
    }

    const { trucks, allowedIds } = await getAuthorizedTrucks(req.profile, [truckId]);
    const truck = trucks.find((t) => t.id === truckId);

    if (!truck) {
      return next(new AppError('Camión no encontrado', 404, 'ERR_TRUCK_NOT_FOUND'));
    }

    if (!allowedIds.has(truck.id)) {
      return next(
        new AppError(
          `No tienes permiso para ver la ubicación del camión ${truck.id}`,
          403,
          'ERR_FORBIDDEN_TRUCK'
        )
      );
    }

    const { data: latestPoint, error: pointError } = await supabase
      .from('gps_tracking')
      .select('id, truck_id, location, speed_kmh, recorded_at')
      .eq('truck_id', truck.id)
      .order('recorded_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (pointError) {
      return next(
        new AppError(
          `Error al consultar última ubicación: ${pointError.message}`,
          500,
          'ERR_DB_SELECT'
        )
      );
    }

    if (!latestPoint) {
      return next(
        new AppError(
          `No hay registros de telemetría para el camión ${truck.plate || truck.id}`,
          404,
          'ERR_TELEMETRY_NOT_FOUND'
        )
      );
    }

    const coords = extractLatLng(latestPoint.location);

    logger.info(`Última ubicación consultada para camión ${truck.id} por usuario ${req.user.id}`);

    res.status(200).json({
      status: 'success',
      data: {
        truck_id: truck.id,
        plate: truck.plate,
        driver_id: truck.driver_id,
        lat: coords ? coords.lat : null,
        lng: coords ? coords.lng : null,
        location: latestPoint.location,
        speed_kmh: latestPoint.speed_kmh,
        recorded_at: latestPoint.recorded_at
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;