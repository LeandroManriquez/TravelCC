const supabase = require('../config/supabase');
const AppError = require('../utils/appError');

/**
 * Debe usarse DESPUÉS de requireRole.
 * Los jefes de flota (admin) solo pueden usar las funciones de flota si el
 * plan de SU flota está activo. A los conductores no les afecta.
 */
const requireActiveFleetPlan = async (req, res, next) => {
  try {
    if (req.profile.role !== 'admin') return next();

    if (!req.profile.fleet_id) {
      return next(new AppError('Tu cuenta no tiene una flota asociada', 409, 'ERR_NO_FLEET'));
    }

    const { data: fleet, error } = await supabase
      .from('fleets')
      .select('plan_status')
      .eq('id', req.profile.fleet_id)
      .maybeSingle();

    if (error) {
      return next(new AppError('No se pudo verificar el plan de la flota', 500, 'ERR_FLEET_LOOKUP'));
    }

    if (!fleet || fleet.plan_status !== 'active') {
      return next(
        new AppError(
          'Necesitas activar el plan de jefe de flota para usar esta función',
          402,
          'ERR_PLAN_INACTIVE'
        )
      );
    }

    next();
  } catch (err) {
    next(err);
  }
};

module.exports = requireActiveFleetPlan;
