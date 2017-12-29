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
  # Remove all stuck active jobs on start
  if err then return handle err
  logger.info "[index.coffee] There are #{ids.length} active jobs in kue."
queue.on 'error', (err) ->
  logger.info "[index.coffee] We received an error in kue."
  handle err
queue.watchStuckJobs 1000
(require './osu_player_lookup') queue
(require './create_tweet')()
getIfLeader (err, result) ->
  if err
    logger.error err

# Our scheduler for midnight every day
cron.schedule '0 13 * * *', ->
  logger.info '[CRON SCHEDULER] TIME TO POST TWEETS!'
  getIfLeader (err, isLeader) ->
    if err and variables.environment isnt "development"
      logger.error '[CRON SCHEDULER] FAILED TO SEE IF WE ARE THE LEADER. ABORTING!'
    else
      if isLeader || variables.environment is "development"
        ## We can start creating jobs
        # Get ObjectIDs of users who have an osu player set and have turned on tweet posting
        userModel.distinct '_id', {'osuSettings.enabled': true, 'osuSettings.player': { $ne: null}}, (err, usersToPost) ->
          if err
            logger.error "[CRON SCHEDULER] ERROR OCCURRED WHILE TRYING TO GET LIST OF USERS TO POST TWEETS FOR"
            logger.error err
            handle err
          else
            logger.info "[CRON SCHEDULER] WE GOT OUR LIST OF USERS (#{usersToPost.length} users)"
            # Now we have our list of users
            # We want to copy the list into a variable, but we don't want to simply reference it, we need a fresh object.
            profilesNotStarted = JSON.parse(JSON.stringify(usersToPost))
            profilesNotFinished = JSON.parse(JSON.stringify(usersToPost))
            postingInterval = setInterval postingAlgorithmFunction, 60000
            postingAlgorithmFunction()
      else
        logger.info '[CRON SCHEDULER] IT SEEMS THAT WE AREN\'T THE LEADER PROCESS, NO NEED TO DO ANYTHING'

cron.schedule '0 16 * * *', ->
  if postingInterval isnt null
    logger.error '[4PM UTC CRON] It appears that the posting algorithm is still going for some reason. Stopping it...'
    clearInterval postingInterval
    postingInterval = null
  else
    logger.info '[4PM UTC CRON] It seems that the posting algorithm stopped correctly.'

postingAlgorithmFunction = ->
  logger.info "[postingAlgorithmFunction] Running posting algorithm"
  # Check to see if we have any more people who we need to post tweets for
  if profilesNotFinished.filter(Boolean).length is 0
    logger.info "[postingAlgorithmFunction] We don't have any more users we need to post tweets for, stopping interval"
    clearInterval postingInterval
    return postingInterval = null
  # All jobs have been started, but not all have been finished yet, it seems.
  else if profilesNotStarted.length is 0
    logger.info profilesNotFinished
    return logger.info "[postingAlgorithmFunction] We don't have any more jobs to start, but it looks like some of the jobs just haven't finished yet"
  jobsToStart = []
  if activeJobs < 250 # We can queue up more jobs
    # If we have fewer than 250 - active jobs, then we just queue the rest of the jobs
    if 250 - activeJobs >= profilesNotStarted.length
      jobsToStart = profilesNotStarted.splice(0, profilesNotStarted.length)
    # Otherwise, start the amount of jobs that we can (250 - activeJobs)
    else
      jobsToStart = profilesNotStarted.splice(0, 250 - activeJobs)
    a.each jobsToStart, (objectId, cb) ->
      activeJobs++
      logger.debug "Creating new job for user #{objectId}"
      newJob = tweetQueue.createJob({
        id: objectId
      })
      newJob.timeout(60000).save()
      newJob.once 'succeeded', (result) ->
        logger.info "[postingAlgorithm] Successfully posted image for userId #{objectId}"
        activeJobs--
        `delete profilesNotFinished[profilesNotFinished.indexOf(objectId)]`
      newJob.once 'failed', (err) ->
        logger.error "[postingAlgorithm] Failed to post image for userId #{objectId}"
        activeJobs--
        `delete profilesNotFinished[profilesNotFinished.indexOf(objectId)]`
        logger.error err
      cb()
    , (err) ->
      if err
        logger.error '[postingAlgorithmFunction] Error occurred while queueing up the new jobs'
        logger.error err
      else
        logger.info "Successfully queued up #{jobsToStart.length} jobs"
    # Now we can go about queueing those jobs
  else # We can't queue up any more jobs
    logger.info "[postingAlgorithmFunction] We are working on too many jobs right now, we can't add any more"
