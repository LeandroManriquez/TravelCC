const { z } = require('zod');
const AppError = require('../utils/appError');

// Esquema para un solo punto de telemetría (Estándar WGS 84)
const telemetryPointSchema = z.object({
  device_id: z.string().min(1, 'El ID del dispositivo es obligatorio'),
  latitude: z.number().min(-90).max(90, 'Latitud inválida (debe estar entre -90 y 90)'),
  longitude: z.number().min(-180).max(180, 'Longitud inválida (debe estar entre -180 y 180)'),
  speed: z.number().nonnegative('La velocidad no puede ser negativa'),
  heading: z.number().min(0).max(360).optional(), // Dirección en grados (0-360)
  timestamp: z.string().datetime('El timestamp debe tener formato ISO 8601 válido')
});

// Esquema principal que permite recibir un punto único o un arreglo (Batching por cortes de 4G)
const telemetryPayloadSchema = z.union([
  telemetryPointSchema,
  z.array(telemetryPointSchema).min(1, 'El lote no puede estar vacío')
]);

const validateTelemetry = (req, res, next) => {
  try {
    // Valida y sanitiza el body contra el esquema
    req.body = telemetryPayloadSchema.parse(req.body);
    next();
  } catch (error) {
    // Si Zod falla, extraemos los mensajes de error de forma limpia
    const errorMessages = error.errors.map(err => `${err.path.join('.')}: ${err.message}`).join(', ');
    return next(new AppError(`Error de validación en telemetría: ${errorMessages}`, 400, 'ERR_VALIDATION_FAILED'));
  }
};

module.exports = validateTelemetry;