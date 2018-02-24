# Ok, this is our Kue queue, which will handle how jobs are handled by our workers
queue = require('../util/queue')
kue = require 'kue'

Queue = require 'bee-queue'
tweetQueue = new Queue 'create-queue', {
  redis: require('../util/redis')
  isWorker: false
}
activeJobs = 0
# Import the logger
logger = require('../util/logger')

# User Model
userModel = (require '../database/index').models.userModel

# Rollbar
handle = require('../util/rollbar').handle

# Variables
variables = require '../util/variables'

# Cron
cron = require 'node-cron'

# Redis client
client = require '../util/redis'

# List of people whose tweets we haven't finished yet
profilesNotFinished = []

# List of people we still need to start to make tweets for
profilesNotStarted = []

# List of profiles we are currently working on
profilesWeAreWorkingOn = 0

# Posting Interval variable (For storing our intertval)
postingInterval = null

# Port to listen on
listenPort = if variables.environment is "production" then variables.port else 8081

# Async
a = require 'async'

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
queue.inactive (err, ids) ->
  if err then return handle err
  logger.info "[index.coffee] There are #{ids.length} inactive jobs in kue."
queue.active (err, ids) ->
  # Remove all stuck active jobs on start
  if err then return handle err
  logger.info "[index.coffee] There are #{ids.length} active jobs in kue."
queue.on 'error', (err) ->
  logger.info "[index.coffee] We received an error in kue."
  handle err
queue.watchStuckJobs 1000
(require './osu_player_lookup') queue
(require './create_tweet')()
