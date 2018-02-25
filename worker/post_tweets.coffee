# Ok, this is our Kue queue, which will handle how jobs are handled by our workers
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

# List of people whose tweets we haven't finished yet
profilesNotFinished = []

# List of people we still need to start to make tweets for
profilesNotStarted = []

# List of profiles we are currently working on
profilesWeAreWorkingOn = 0

# Posting Interval variable (For storing our intertval)
postingInterval = null

# Async
a = require 'async'

###
START
###
userModel.distinct '_id', {'osuSettings.enabled': true, 'osuSettings.player': { $ne: null}}, (err, usersToPost) ->
  if err
    logger.error "ERROR OCCURRED WHILE TRYING TO GET LIST OF USERS TO POST TWEETS FOR"
    logger.error err
    handle err
  else
    logger.info "There are #{usersToPost.length} users we need to post for"

    # Now we have our list of users
    # We want to copy the list into a variable, but we don't want to simply reference it, we need a fresh object.
    profilesNotStarted = JSON.parse(JSON.stringify(usersToPost))
    profilesNotFinished = JSON.parse(JSON.stringify(usersToPost))

    # Create the interval to create and manage the jobs, then manually run the first instance
    postingInterval = setInterval postingAlgorithmFunction, 60000
    postingAlgorithmFunction()

setTimeout ->
  if postingInterval isnt null
    logger.error 'It appears that the posting algorithm is still going for some reason. Stopping it...'
    clearInterval postingInterval
    process.exit 1
  else
    logger.info 'It seems that the posting algorithm stopped correctly.'
    process.exit 0
, 3600000
postingAlgorithmFunction = ->
  logger.info "[postingAlgorithmFunction] Running posting algorithm"
  # Check to see if we have any more people who we need to post tweets for
  if profilesNotFinished.filter(Boolean).length is 0
    logger.info "[postingAlgorithmFunction] We don't have any more users we need to post tweets for, exiting"
    return process.exit 0
  # All jobs have been started, but not all have been finished yet, it seems.
  else if profilesNotStarted.length is 0
    logger.info profilesNotFinished
    return logger.info "[postingAlgorithmFunction] We don't have any more jobs to start, but it looks like some of the jobs just haven't finished yet"
  jobsToStart = []
  if activeJobs < 150 # We can queue up more jobs
    # If we have fewer than 120 - active jobs, then we just queue the rest of the jobs
    if 150 - activeJobs >= profilesNotStarted.length
      jobsToStart = profilesNotStarted.splice(0, profilesNotStarted.length)
    # Otherwise, start the amount of jobs that we can (150 - activeJobs)
    else
      jobsToStart = profilesNotStarted.splice(0, 150 - activeJobs)
    a.each jobsToStart, (objectId, cb) ->
      process.nextTick ->
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
