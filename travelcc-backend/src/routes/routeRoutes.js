const express = require('express');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const requireRole = require('../middlewares/requireRole');
const { canAccessTruck } = require('../utils/truckAccess');
const supabase = require('../config/supabase');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');

const OSRM_BASE_URL = process.env.OSRM_URL || 'https://router.project-osrm.org';
const PROXIMITY_METERS = Number(process.env.RESTRICTION_PROXIMITY_METERS || 50);

/**
 * Llama a OSRM para obtener una o más rutas alternativas entre origen y destino.
 * OSRM espera coordenadas en formato lng,lat.
 */
async function fetchOsrmRoutes(origin, destination) {
  const coords = `${origin.lng},${origin.lat};${destination.lng},${destination.lat}`;
  const url = `${OSRM_BASE_URL}/route/v1/driving/${coords}?overview=full&geometries=geojson&alternatives=true&steps=false`;

  const response = await fetch(url);
  if (!response.ok) {
    throw new AppError(
      `OSRM respondió con estado ${response.status}`,
      502,
      'ERR_OSRM_UNAVAILABLE'
    );
  }

  const data = await response.json();
  if (data.code !== 'Ok' || !Array.isArray(data.routes) || data.routes.length === 0) {
    throw new AppError(
      'No se pudo calcular una ruta válida con OSRM',
      404,
      'ERR_ROUTE_NOT_FOUND'
    );
  }

  return data.routes;
}



/**
 * Evalúa restricciones de mop_restrictions contra la geometría GeoJSON de una ruta.
 * Requiere tener creada una función RPC en Postgres/PostGIS o hacer el chequeo en SQL.
 */
async function evaluateRestrictionsForGeometry(geometryGeoJson, truckHeight, truckWeight) {
  // Consultamos restricciones que intersecten o estén dentro de PROXIMITY_METERS de la ruta
  // usando una función RPC en Supabase/PostGIS (la definimos en el paso siguiente).
  const { data, error } = await supabase.rpc('check_route_restrictions', {
    route_geojson: geometryGeoJson,
    buffer_meters: PROXIMITY_METERS
  });

  if (error) {
    throw new AppError(
      `Error al consultar mop_restrictions: ${error.message}`,
      500,
      'ERR_RESTRICTIONS_QUERY'
    );
  }

  const restrictions = data || [];

  const evaluated = restrictions.map((r) => {
    const heightExceeded =
      r.max_height_meters !== null &&
      r.max_height_meters !== undefined &&
      truckHeight !== null &&
      truckHeight !== undefined &&
      Number(truckHeight) > Number(r.max_height_meters);

    const weightExceeded =
      r.max_weight_tons !== null &&
      r.max_weight_tons !== undefined &&
      truckWeight !== null &&
      truckWeight !== undefined &&
      Number(truckWeight) > Number(r.max_weight_tons);

    const isBlocking = heightExceeded || weightExceeded;

    return {
      id: r.id,
      description: r.description,
      max_height_meters: r.max_height_meters,
      max_weight_tons: r.max_weight_tons,
      distance_meters: r.distance_meters,
      height_exceeded: heightExceeded,
      weight_exceeded: weightExceeded,
      is_blocking: isBlocking
    };
  });

  const blockingRestrictions = evaluated.filter((item) => item.is_blocking);
  const warningRestrictions = evaluated.filter((item) => !item.is_blocking);

  return {
    total_matched: evaluated.length,
    blocking_count: blockingRestrictions.length,
    warning_count: warningRestrictions.length,
    is_route_compatible: blockingRestrictions.length === 0,
    restrictions: evaluated
  };
}

// POST /api/v1/routes/plan
router.post('/plan', protect, requireRole('driver'), async (req, res, next) => {
  try {
    const { truck_id, origin, destination } = req.body || {};
    //console.log('BODY RECIBIDO:', JSON.stringify(req.body));

    if (
      !truck_id ||
      !origin ||
      typeof origin.lat !== 'number' ||
      typeof origin.lng !== 'number' ||
      !destination ||
      typeof destination.lat !== 'number' ||
      typeof destination.lng !== 'number'
    ) {
      return next(
        new AppError(
          'Debes enviar truck_id, origin ({ lat, lng }) y destination ({ lat, lng }) válidos',
          400,
          'ERR_INVALID_ROUTE_PAYLOAD'
        )
      );
    }

    // 1. Buscar camión y verificar permiso según rol (anti-IDOR)
    const { data: truck, error: truckError } = await supabase
      .from('trucks')
      .select('id, plate, driver_id, fleet_id, height_meters, weight_tons')
      .eq('id', truck_id)
      .single();

    if (truckError || !truck) {
      return next(new AppError('Camión no encontrado', 404, 'ERR_TRUCK_NOT_FOUND'));
    }

    const hasAccess = canAccessTruck(req.profile, truck);

    if (!hasAccess) {
      return next(
        new AppError(
          `No tienes permiso para planificar rutas del camión ${truck.id}`,
          403,
          'ERR_FORBIDDEN_TRUCK'
        )
      );
    }

    // 3. Obtener rutas desde OSRM
    const osrmRoutes = await fetchOsrmRoutes(origin, destination);

    // 4. Evaluar cada ruta contra mop_restrictions y asignar costo/peso base
    const evaluatedRoutes = [];
    for (let i = 0; i < osrmRoutes.length; i++) {
      const route = osrmRoutes[i];
      const check = await evaluateRestrictionsForGeometry(
        route.geometry,
        truck.height_meters,
        truck.weight_tons
      );

      // Costo base: duracion en segundos + penalizacion por restricciones bloqueantes/cercanas
      const baseCost = Number(route.duration || 0);
      const blockingPenalty = check.blocking_count * 100000;
      const warningPenalty = check.warning_count * 300;
      const routeWeightScore = Math.round(baseCost + blockingPenalty + warningPenalty);

      evaluatedRoutes.push({
        index: i,
        distance_meters: route.distance,
        duration_seconds: route.duration,
        route_weight_score: routeWeightScore,
        is_compatible: check.is_route_compatible,
        geometry: route.geometry,
        restrictions_summary: {
          total_matched: check.total_matched,
          blocking_count: check.blocking_count,
          warning_count: check.warning_count
        },
        restrictions: check.restrictions
      });
    }

    // Ordenamos por menor peso/costo (rutas compatibles primero)
    evaluatedRoutes.sort((a, b) => a.route_weight_score - b.route_weight_score);

    logger.info(
      `Ruta evaluada para camión ${truck.plate} (${truck.id}): ${evaluatedRoutes.length} opción(es) desde OSRM`
    );

    res.status(200).json({
      status: 'success',
      data: {
        truck: {
          id: truck.id,
          plate: truck.plate,
          height_meters: truck.height_meters,
          weight_tons: truck.weight_tons
        },
        recommended_route: evaluatedRoutes[0],
        routes: evaluatedRoutes
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;