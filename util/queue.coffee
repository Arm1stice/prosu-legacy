variables = require './variables'
handle = (require '../util/rollbar').handle
# Setup kue
kue = require 'kue'
queue = kue.createQueue {
  redis: variables.redisUrl
}
queue.on 'error', (err) ->
  return handle err
module.exports = queue
