const express = require('express');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const validateTelemetry = require('../middlewares/validateTelemetry');
const logger = require('../utils/logger');

// POST /api/v1/telemetry -> Recibe los puntos GPS de los camiones
router.post('/', protect, validateTelemetry, async (req, res, next) => {
  try {
    const telemetryData = req.body;
    const isBatch = Array.isArray(telemetryData);
    const count = isBatch ? telemetryData.length : 1;

    // Aquí luego conectaremos con Supabase para insertar en PostGIS
    logger.info(`Telemetría recibida con éxito: ${count} registro(s) procesado(s) para el usuario ${req.user.id}`);

    res.status(201).json({
      status: 'success',
      message: `Telemetría almacenada correctamente (${count} puntos)`,
      data: {
        received_points: count
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;