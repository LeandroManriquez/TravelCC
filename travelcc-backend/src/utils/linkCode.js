const crypto = require('crypto');

// Sin caracteres ambiguos (0/O, 1/I/L): se puede dictar o copiar sin errores.
const ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const CODE_LENGTH = 8;

// Genera un código aleatorio criptográficamente seguro, ej. "K7M29QXP".
function generateLinkCode() {
  let code = '';
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += ALPHABET[crypto.randomInt(ALPHABET.length)];
  }
  return code;
}

// Lo que escribe el usuario ("k7m2-9qxp", " K7M2 9QXP ") -> "K7M29QXP".
function normalizeLinkCode(input) {
  return String(input || '').replace(/[^A-Za-z0-9]/g, '').toUpperCase();
}

// Para mostrar: "K7M29QXP" -> "K7M2-9QXP".
function formatLinkCode(code) {
  return `${code.slice(0, 4)}-${code.slice(4)}`;
}

module.exports = { generateLinkCode, normalizeLinkCode, formatLinkCode };
