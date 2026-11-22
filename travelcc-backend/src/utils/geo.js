// Normaliza location (GeoJSON Point o WKT POINT(lng lat)) a { lat, lng }
function extractLatLng(location) {
  if (!location) return null;

  if (
    typeof location === 'object' &&
    Array.isArray(location.coordinates) &&
    location.coordinates.length >= 2
  ) {
    return {
      lng: Number(location.coordinates[0]),
      lat: Number(location.coordinates[1])
    };
  }

  if (typeof location === 'string') {
    const match = location.match(/POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)/i);
    if (match) {
      return {
        lng: Number(match[1]),
        lat: Number(match[2])
      };
    }
  }

  return null;
}

module.exports = { extractLatLng };
