Rollbar = require 'rollbar'
variables = require './variables'
rollbar = new Rollbar
  accessToken: variables.rollbarAPI
  environment: variables.environment
  handleUncaughtExceptions: if variables.environment isnt 'development' then true else false
  handleUnhandledRejections: if variables.environment isnt 'development' then true else false

module.exports.handle = (err) ->
  console.error err
  rollbar.critical err, (err2) ->
    if err2?
      throw err2
