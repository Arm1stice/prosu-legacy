rollbar = require 'rollbar'
variables = require './variables'
rollbar.init variables.rollbarAPI,
  endpoint: variables.rollbarEndpoint
  environment: variables.environment

module.exports.setup = () ->
  rollbar.handleUncaughtExceptions null,
    exitOnUncaughtException: true
module.exports.handle = (err) ->
  console.error err
  rollbar.handleError err, (err2) ->
    if err2?
      throw err2
