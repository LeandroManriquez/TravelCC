const supabase = require('../config/supabase');
const AppError = require('./appError');

/**
 * Regla única de acceso a camiones (anti-IDOR):
 *  - admin  (jefe de flota): camiones de SU flota.
 *  - driver (conductor):     solo camiones donde él es el conductor asignado.
 */
function canAccessTruck(profile, truck) {
  if (!profile || !truck) return false;

  if (profile.role === 'admin') {
    return Boolean(profile.fleet_id) && truck.fleet_id === profile.fleet_id;
  }

  if (profile.role === 'driver') {
    return truck.driver_id === profile.id;
  }

  return false;
}

// Busca los camiones pedidos y devuelve cuáles puede usar el perfil.
async function getAuthorizedTrucks(profile, truckIds) {
  const { data: trucks, error } = await supabase
    .from('trucks')
    .select('id, plate, driver_id, fleet_id')
    .in('id', truckIds);

  if (error) {
    throw new AppError('Error al validar camiones asignados', 500, 'ERR_TRUCK_LOOKUP');
  }

  const allTrucks = trucks || [];
  const allowedTrucks = allTrucks.filter((t) => canAccessTruck(profile, t));

  return {
    trucks: allTrucks,
    allowedTrucks,
    allowedIds: new Set(allowedTrucks.map((t) => t.id))
  };
}

module.exports = { canAccessTruck, getAuthorizedTrucks };
