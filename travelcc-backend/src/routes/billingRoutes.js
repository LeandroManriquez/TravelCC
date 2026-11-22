const express = require('express');
const router = express.Router();
const protect = require('../middlewares/authMiddleware');
const requireRole = require('../middlewares/requireRole');
const supabase = require('../config/supabase');
const AppError = require('../utils/appError');
const logger = require('../utils/logger');

// POST /api/v1/billing/simulate-checkout
// *** SIMULACIÓN PARA DEMOSTRACIÓN: no cobra nada ni se conecta a ningún banco. ***
// Solo funciona si el servidor tiene ALLOW_SIMULATED_PAYMENTS=true en su .env.
// Cuando exista un pago real, este endpoint se reemplaza por el webhook del proveedor
// de pagos; el resto de la app (requireActiveFleetPlan) no cambia.
router.post('/simulate-checkout', protect, requireRole('admin'), async (req, res, next) => {
  try {
    if (process.env.ALLOW_SIMULATED_PAYMENTS !== 'true') {
      return next(
        new AppError(
          'Los pagos simulados están desactivados en este servidor',
          403,
          'ERR_SIMULATED_PAYMENTS_DISABLED'
        )
      );
    }

    const fleetId = req.profile.fleet_id;

    if (!fleetId) {
      return next(new AppError('Tu cuenta no tiene una flota asociada', 409, 'ERR_NO_FLEET'));
    }

    const activatedAt = new Date().toISOString();

    const { error } = await supabase
      .from('fleets')
      .update({ plan_status: 'active', plan_activated_at: activatedAt })
      .eq('id', fleetId);

    if (error) {
      return next(new AppError('No se pudo activar el plan', 500, 'ERR_PLAN_ACTIVATE'));
    }

    logger.info(`Plan de la flota ${fleetId} activado con pago SIMULADO por ${req.profile.id}`);

    res.status(200).json({
      status: 'success',
      message: 'Plan activado (pago simulado, modo demostración)',
      data: { simulated: true, plan_status: 'active', plan_activated_at: activatedAt }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
