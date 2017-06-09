Rollbar = require 'rollbar'
variables = require './variables'
rollbar = new Rollbar
  accessToken: variables.rollbarAPI
  debug: true
  ignoredMessages: [
    "Error: Failed to find request token in session"
  ]
  handleUncaughtExceptions: if variables.environment isnt 'development' then true else false
  handleUnhandledRejections: if variables.environment isnt 'development' then true else false
  payload:
    environment: variables.environment
module.exports.handle = (err) ->
  console.error err
  rollbar.critical err, (err2) ->
    if err2?
      throw err2
