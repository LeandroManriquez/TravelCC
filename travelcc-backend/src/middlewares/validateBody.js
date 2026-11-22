const AppError = require('../utils/appError');

/**
 * Valida req.body contra un esquema de Zod.
 * Deja en req.body solo los datos ya validados y limpios.
 */
const validateBody = (schema) => (req, res, next) => {
  const result = schema.safeParse(req.body);

  if (!result.success) {
    const details = result.error.issues
      .map((issue) => `${issue.path.join('.') || 'body'}: ${issue.message}`)
      .join(', ');
    return next(new AppError(`Datos inválidos: ${details}`, 400, 'ERR_VALIDATION_FAILED'));
  }

  req.body = result.data;
  next();
};

module.exports = validateBody;
