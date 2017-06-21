logger = require './logger'
variables = require './variables'

# Setup the redis connection
redis = require 'redis'
client = redis.createClient variables.redisUrl
client.once 'ready', ->
  logger.debug "Connected to the Redis server"
client.on 'error', (err) ->
  throw err
module.exports = client
