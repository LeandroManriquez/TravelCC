const supabase = require('../config/supabase');
const AppError = require('../utils/appError');

/**
 * Debe usarse DESPUÉS de `protect`.
 * Carga el perfil del usuario (id, full_name, role, fleet_id) en req.profile
 * y, si se indican roles, rechaza con 403 a quien no tenga uno de ellos.
 *
 * Uso:
 *   requireRole('admin')            -> solo jefes de flota
 *   requireRole('admin', 'driver')  -> ambos roles
 *   requireRole()                   -> cualquiera con perfil (solo carga req.profile)
 */
const requireRole = (...allowedRoles) => async (req, res, next) => {
  try {
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('id, full_name, role, fleet_id')
      .eq('id', req.user.id)
      .maybeSingle();

    if (error) {
      return next(new AppError('No se pudo verificar el perfil del usuario', 500, 'ERR_PROFILE_LOOKUP'));
    }

    if (!profile) {
      return next(new AppError('El usuario no tiene un perfil asociado', 403, 'ERR_PROFILE_NOT_FOUND'));
    }

    if (allowedRoles.length > 0 && !allowedRoles.includes(profile.role)) {
      return next(new AppError('No tienes permisos para realizar esta acción', 403, 'ERR_FORBIDDEN_ROLE'));
    }

    req.profile = profile;
    next();
  } catch (err) {
    next(err);
  }
};

module.exports = requireRole;
