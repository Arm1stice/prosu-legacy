variables = require './variables'
handle = (require './rollbar').handle
logger = require './logger'
# Setup kue
kue = require 'kue'
queue = kue.createQueue {
  redis: variables.redisUrl
}
queue.on 'error', (err) ->
  return handle err

# If we are asked to shutdown, we want to be able to make sure that we finish all of the current jobs, and not start any more. This function takes care of that for us
gracefulShutdown = ->
  logger.info "Attempting to gracefully shut down..."
  queue.shutdown 20000, (err) ->
    if err
      handle err
      process.exit 1
    else
      process.exit 0
process.once 'SIGTERM', gracefulShutdown
process.once 'SIGINT', gracefulShutdown

module.exports = queue
