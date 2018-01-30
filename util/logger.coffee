winston = require 'winston'
require('winston-papertrail').Papertrail

variables = require './variables'
consoleLogger = new winston.transports.Console({
  level: 'error',
  timestamp: (() -> new Date().toString().substr(0, 24)),
  colorize: true
})
transportsList = [consoleLogger]
# Papertrail setup
if variables.papertrailEnabled
  console.log "ENABLING PAPERTRAIL"
  if variables.papertrailHost is null
    console.error "Papertrail is enabled but the PAPERTRAIL_HOST variable isn't set. Disabling Papertrail"
  else if variables.papertrailPort is null
    console.error "Papertrail is enabled but the PAPERTRAIL_PORT variable isn't set. Disabling Papertrail"
  else
    winstonPapertrail = new winston.transports.Papertrail {
      host: variables.papertrailHost,
      port: variables.papertrailPort,
      program: process.env.PROCTYPE
    }
    winstonPapertrail.on 'error', (err) ->
      console.error "WINSTON PAPERTRAIL GAVE AN ERROR:"
      console.error err
    transportsList.push winstonPapertrail

logger = new winston.Logger({
  levels: {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3
  },
  transports: transportsList
})

module.exports = logger
