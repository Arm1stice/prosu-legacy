logger = require './logger'
variables = require './variables'
# Setup the redis connection
redis = require 'redis'
client = redis.createClient variables.redisUrl
client.once 'ready', ->
  logger.info "Connected to the Redis server"

module.exports = client
