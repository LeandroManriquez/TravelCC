const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const logger = require('./utils/logger');
const errorHandler = require('./middlewares/errorHandler');
const AppError = require('./utils/appError');

const app = express();

// 1. Seguridad Perimetral con Helmet
app.use(helmet());

// 2. Configuración de CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// 3. Rate Limiter Estricto exclusivo para rutas de Autenticación / Login 
// (Protege contra fuerza bruta, sin afectar la telemetría GPS de los camiones)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 20, // Límite estricto de 20 intentos por IP para evitar ataques
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: 'fail',
    error_code: 'ERR_SYS_RATE_LIMIT',
    message: 'Demasiados intentos de autenticación desde esta IP. Intente más tarde.'
  }
});

// Aplicamos el limitador SOLO a la ruta de auth (cuando la crearemos)
// app.use('/api/v1/auth', authLimiter); // Lo dejamos listo para cuando integremos Supabase Auth

// 4. Parseador de JSON con límite de tamaño
app.use(express.json({ limit: '10kb' }));

// 5. Ruta de Health-Check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'TravelCC Backend operational and secure 🚀'
  });
});

// 6. Manejador para rutas no encontradas (404)
app.all('*', (req, res, next) => {
  next(new AppError(`La ruta ${req.originalUrl} no existe en este servidor`, 404, 'ERR_SYS_NOT_FOUND'));
});

// 7. Middleware global de errores
app.use(errorHandler);

// 8. Encendido del servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Servidor TravelCC corriendo de forma segura en el puerto ${PORT}`);
});