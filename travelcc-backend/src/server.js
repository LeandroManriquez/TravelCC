const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const telemetryRoutes = require('./routes/telemetryRoutes');
const rateLimit = require('express-rate-limit');
const routeRoutes = require('./routes/routeRoutes');
const meRoutes = require('./routes/meRoutes');
const fleetRoutes = require('./routes/fleetRoutes');
const billingRoutes = require('./routes/billingRoutes');
const reportRoutes = require('./routes/reportRoutes');
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
app.use(express.json({ limit: '100kb' }));

// 5. Ruta de Health-Check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'TravelCC Backend operational and secure 🚀'
  });
});

// ...
const telemetryLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
  max: 30, // Máximo 30 envíos por minuto por IP (1 cada 2 segundos)
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: 'fail',
    error_code: 'ERR_TELEMETRY_RATE_LIMIT',
    message: 'Demasiadas peticiones de telemetría. Intente en unos segundos.'
  }
});

app.use('/api/v1/telemetry', telemetryLimiter, telemetryRoutes);  
// 6. Rutas principales y manejador para rutas no encontradas (404)
app.use('/api/v1/reports', reportRoutes);
app.use('/api/v1/me', meRoutes);
app.use('/api/v1/fleet', fleetRoutes);
app.use('/api/v1/billing', billingRoutes);
app.use('/api/v1/routes', routeRoutes);
app.use('/api/v1/telemetry', telemetryRoutes);
app.all(/(.*)/, (req, res, next) => {
  next(new AppError(`La ruta ${req.originalUrl} no existe en este servidor`, 404, 'ERR_SYS_NOT_FOUND'));
});

// 7. Middleware global de errores
app.use(errorHandler);

// 8. Encendido del servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Servidor TravelCC corriendo de forma segura en el puerto ${PORT}`);
});