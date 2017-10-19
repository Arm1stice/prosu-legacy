# Ok, this is our Kue queue, which will handle how jobs are handled by our workers
queue = require('../util/queue')

# Import the logger
logger = require('../util/logger')

# Rollbar
handle = require('../util/rollbar').handle

# Variables
variables = require '../util/variables'

# Redis client
client = require '../util/redis'

listenPort = if variables.environment is "production" then variables.port else 8081
# Create our leadership testing server
logger.debug "[index.coffee] Setting up web server for worker process..."
app = require('express')()
app.get '/', (req, res) ->
  res.end process.env.HOSTNAME # Return the hostname that Flynn has generated for us, which should be unique
app.listen listenPort, (err) ->
  if err then throw err
  logger.debug "[index.coffee] Web server now up and running on port #{listenPort}"

# The request client
request = require 'request'

# The function to determine that returns whether or not we are the leader
getIfLeader = (done) ->
  logger.debug "[getIfLeader] Getting if we are the leader..."
  request "http://leader.#{process.env.FLYNN_APP_NAME}-worker-web.discoverd:#{listenPort}/", (err, res, body) ->
    if err
      logger.error "[getIfLeader] We got an error while trying to figure out if our process is the leader"
      return done err
    if res.statusCode isnt 200
      logger.error "[getIfLeader] The response code from the leader process wasn't 200 for some reason"
      return done Error "Response code wasn't 200! Was #{res.statusCode}"
    result = if body is process.env.HOSTNAME then true else false
    logger.debug "[getIfLeader] Leader Result: #{result}. Expected #{process.env.HOSTNAME} but got #{body}"
    return done null, result # If the response we get is equal to our randomString, then we are the leader
queue.inactive (err, ids) ->
  if err then return handle err
  logger.info "[index.coffee] There are #{ids.length} inactive jobs in kue."
queue.active (err, ids) ->
  if err then return handle err
  logger.info "[index.coffee] There are #{ids.length} active jobs in kue."
queue.on 'error', (err) ->
  logger.info "[index.coffee] We received an error in kue."
  handle err
queue.watchStuckJobs 1000
(require './osu_player_lookup') queue
(require './create_tweet') queue
getIfLeader (err, result) ->
  if err then logger.error err
