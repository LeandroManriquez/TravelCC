const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';
  err.errorCode = err.errorCode || 'ERR_SYS_500';


  logger.error(`[${err.errorCode}] ${err.message}`, {
    path: req.path,
    method: req.method,
    stack: err.stack
  });

  
  let clientMessage = err.message;

  if (err.statusCode === 500 && !err.isOperational) {
    clientMessage = 'Ocurrió un error interno en el servidor. Por favor, intente más tarde.';
  }

 
  res.status(err.statusCode).json({
    status: err.status,
    error_code: err.errorCode,
    message: clientMessage
  });
};

module.exports = errorHandler;