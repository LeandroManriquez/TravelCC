const supabase = require('../config/supabase');
const AppError = require('../utils/appError');

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new AppError('No se proporcionó token de autenticación', 401, 'ERR_AUTH_MISSING_TOKEN'));
    }

    const token = authHeader.split(' ')[1];

    // Validar el token directamente con Supabase Auth
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return next(new AppError('Token inválido o expirado', 401, 'ERR_AUTH_INVALID_TOKEN'));
    }

    // Inyectar el usuario autenticado en la petición para los siguientes controladores
    req.user = user;
    next();
  } catch (err) {
    next(new AppError('Error interno en la autenticación', 500, 'ERR_AUTH_INTERNAL'));
  }
};

module.exports = protect;