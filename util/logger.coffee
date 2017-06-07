winston = require 'winston'
consoleLogger = new winston.transports.Console({
  level: 'error',
  timestamp: (() -> new Date().toString().substr(0, 24)),
  colorize: true
})

logger = new winston.Logger({
  levels: {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3
  },
  transports: [consoleLogger]
})

module.exports = logger
