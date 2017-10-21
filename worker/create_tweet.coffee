###
  This file defines the function that will be called when we create a job to generate a tweet for a profile of an osu! player
###

# osu! api module
osu = require './osuApi'

# Logger
logger = require '../util/logger'

# Environment variables
variables = require '../util/variables'

# Error handler
handle = (require '../util/rollbar').handle
# Twitter
twitter = require 'twitter'
# MongoDB User object
osuPlayer = (require '../database/index').models.osuPlayer
osuRequest = (require '../database/index').models.osuRequest
userModel = (require '../database/index').models.userModel
modes = [
  'standard',
  'taiko',
  'ctb',
  'mania'
]

generateImage = require './util/generateImage/index'
Limiter = require 'ratelimiter'
limiter = new Limiter
  id: "tweet_osu_api"
  db: (require '../util/redis')
  max: 250 # 250 requests
  duration: 60000 # Per 60 seconds
tryLimit = (done) ->
  limiter.get (err, limit) ->
    if err
      logger.error "[tryLimit] An error occured while getting the rate limit"
      return done err # Return error
    else
      if limit.remaining
        return done() # Call the function
      # We've hit our rate limit cap, return error = true
      else
        return done true
# Our function
module.exports = (queue) ->
  # When we process the job, we are passed two variables, the job object, and a function to call when we complete our task
  queue.process 'prosu_tweet_creation', 50, (job, done) ->
    # First we have to populate the player saved in their osu!settings
    logger.debug "[prosu_tweet_creation #{job.data.id}] Working on tweet for user #{job.data.id}"
    userId = job.data.id
    userModel.findById userId
    .populate 'osuSettings.player'
    .exec (err, populated_user) ->
      if err
        logger.error "[prosu_tweet_creation 55 #{userId}] Error occured for user #{userId} while populating osuSettings.player"
        logger.error err
        return done err
      # If the tweets aren't enabled
      if not populated_user.osuSettings.enabled
        logger.debug "[prosu_tweet_creation 62 #{job.data.id}] User doesn't have tweets enabled, returning"
        return done "User #{userId} doesn't have tweets enabled"
      # Check to see if we recently posted a tweet
      if populated_user.tweetHistory.length > 0
        # If there was a tweet posted in the last 12 hours, something is wrong. Ignore that if we are in development
        if Date.now() - (populated_user.tweetHistory[populated_user.tweetHistory.length - 1]).datePosted < 43200000 and variables.environment isnt "development"
          logger.debug "[prosu_tweet_creation 69 #{job.data.id}] User has already recently had a tweet posted. Returning..."
          return done "The user #{userId} has a recent tweet posted, something is WRONG"

      if not populated_user.osuSettings.player
        logger.debug "[prosu_tweet_creation 73 #{job.data.id}] This user doesn't have an osu player saved in their profile. Returning..."
        return done "No player saved in this user profile"

      osuPlayer.findById populated_user.osuSettings.player._id
      .populate "modes.#{modes[populated_user.osuSettings.mode]}.checks"
      .exec (err, player) ->
        if err
          logger.error "[prosu_tweet_creation 69] Error occured for user #{userId} while populating osuPlayer checks"
          logger.error err
          return done err
        # Check to see if we already have stats that are from the last hour
        logger.debug "[prosu_tweet_creation 84 #{job.data.id}] Obtained osuPlayer #{player.name} from database"
        checks = player.modes[modes[populated_user.osuSettings.mode]].checks
        if (new Date).getTime() - checks[checks.length - 1].dateChecked > 3600000
          logger.debug "[prosu_tweet_creation 87 #{job.data.id}] Need to get new data. Getting stats..."
          # We need to check for stats again
          requestStats populated_user.osuSettings.player, populated_user.osuSettings.mode, (err, userId) ->
            if err
              logger.error "[prosu_tweet_creation 78] Error occured for user #{userId} while requesting stats"
              logger.error err
              return done err
            createAndPostTweet populated_user, player, (err) ->
              if err
                logger.error "[prosu_tweet_creation 83] Error occured for user #{userId} while creating and posting tweet"
                logger.error err
                return done err
              # Guess it worked LOL
              logger.debug "[prosu_tweet_creation 100 #{job.data.id}] Successfully generated and posted tweet"
              return done(null, userId)
        else
          # We don't need to check for their stats again
          logger.debug "[prosu_tweet_creation 103 #{job.data.id}] We have recent data, we don't need to get new data."
          createAndPostTweet populated_user, player, (err) ->
            if err
              logger.error "[prosu_tweet_creation 92] Error occured for user #{userId} while creating and posting tweet"
              logger.error err
              return done err
            # Guess it worked LOL
            logger.debug "[prosu_tweet_creation 110 #{job.data.id}] Successfully generated and posted tweet"
            return done(null, userId)
## GET THE LATEST STATS FOR A SPECIFIC USER ON A SPECIFIC GAME MODE
requestStats = (user, mode, done) ->
  tryLimit (err) ->
    if err
      if err is true
        done "Prosu is currently under load and it is hitting its rate limit with the osu! API. Please try again later"
      else
        done err
    else
      osu.getUser {
        u: user.userid
        m: mode
      }
      .then (player) ->
        # The user exists
        if player
          logger.debug "Player #{player.name} exists"
          osuPlayer.findOne {
            userid: player.id
          }
          .populate "modes.#{modes[mode]}.checks"
          .exec (err, user) ->
            if err
              logger.error "[create_tweet.coffee] An error occured while looking up a player in osuPlayer"
              return done err # If there was a database error, then we immediately return it
            if user # The user already exists in our database
              shouldSaveUser = false
              shouldSaveRequest = false
              request = null
              logger.info "[create_tweet.coffee] User #{player.name} already exists in our database, we have to check on it"
              # We need to check and see if the user's username might have changed since the last time we saved to the db
              if player.name isnt user.name
                logger.info "[create_tweet.coffee] User with id #{player.id} has an older username, updating it"
                shouldSaveUser = true
                user.name = player.name
              checksArray = user.modes[modes[mode]].checks
              if checksArray.length isnt 0 and (new Date).getTime() - checksArray[checksArray.length - 1].dateChecked > 3600000
                logger.info "[create_tweet.coffee] It's been more than one hour since we last looked up the rank of #{player.name} for mode #{modes[mode]}. Adding to checks array"
                request = new osuRequest {
                  player: user._id
                  data: player
                  dateChecked: (new Date).getTime()
                }
                checksArray.push request._id
                shouldSaveRequest = true
              else if checksArray.length is 0
                logger.info "[create_tweet.coffee] We've never checked the rank on player #{player.name} for mode #{modes[mode]}. Adding it to database..."
                request = new osuRequest {
                  player: user._id
                  data: player
                  dateChecked: (new Date).getTime()
                }
                checksArray.push request._id
                shouldSaveRequest = true
              else
                logger.info "[create_tweet.coffee] We have a recent rank check for #{player.name} under game mode #{modes[mode]}. No need to do anything"
                return done null, user._id
              if shouldSaveRequest
                logger.info "[create_tweet.coffee] We have to save the request for #{player.name}. Doing so...."
                request.save (err) ->
                  if err then return done "An error occurred while saving the stats request to the database"
                  logger.info "[create_tweet.coffee] Saved the request for user #{player.name}. Saving user to database..."
                  user.save (err) ->
                    logger.info "[create_tweet.coffee] Saved #{player.name} to database. Job completed"
                    if err then return done "An error occurred while saving the new user to the database"
                    return done null, user._id
              else if shouldSaveUser
                logger.info "[create_tweet.coffee] We need to save #{player.name} to the database. Doing so..."
                user.save (err) ->
                  if err then return done "An error occurred while saving the new user to the database"
                  logger.info "[create_tweet.coffee] Saved #{player.name} to database. Job completed"
                  return done null, user._id
              return done null, user._id
            else
              logger.info "[create_tweet.coffee] User doesn't exist in our database, we have to make a new entry"
              newUser = new osuPlayer {
                name: player.name
                userid: player.id
                modes:
                  mania:
                    checks: []
                  standard:
                    checks: []
                  taiko:
                    checks: []
                  ctb:
                    checks: []
              }
              request = new osuRequest {
                player: newUser._id
                data: player
                dateChecked: (new Date).getTime()
              }
              request.save (err) ->
                if err then return done "An error occurred while saving the stats request to the database"
                newUser.modes[modes[mode]].checks.push request._id
                newUser.save (err) ->
                  if err then return done "An error occurred while saving the new user to the database"
                  logger.info "[create_tweet.coffee] Saved #{player.name} to database. Job completed"
                  return done null, newUser._id
        # The user doesn't exist
        else
          done "The user you specified doesn't exist or hasn't played that game mode"
      .catch (err) ->
        logger.error "An error occurred"
        logger.error err
        done err, null # Return err, null user

## GENERATE THE IMAGE AND POST THE TWEET TO THE USER'S TWITTER ##
createAndPostTweet = (user, player, done) ->
  # First, create a twitter client based off of the credentials we have stored
  twitterClient = new twitter {
    consumer_key: variables.twitterConsumerKey
    consumer_secret: variables.twitterConsumerSecret

    access_token_key: user.twitter.token
    access_token_secret: user.twitter.tokenSecret
  }

  # First we want to make sure our credentials are correct, or else we are just wasting processor time
  twitterClient.get 'account/verify_credentials', {}, (err, authenticated) ->
    # If we can't authenticate, disable tweet posting, as that means they disabled our access to the application
    if err
      user.osuSettings.enabled = false
      user.save (err) ->
        if err
          return done err
        else
          return done "[createAndPostTweet] Account credentials aren't valid, no longer continuing to attempt posting tweet"
    else # We were able to authenticate
    # Create and post the tweet based off of the information we were given from our job
    generateImage player, user.osuSettings.mode, (err, image) ->
      if err then return done err
      # image is our image buffer

      # Upload image to twitter
      twitterClient.post 'media/upload', {media: image}, (err, media, response) ->
        if err then return done err
        # The status we are going to post
        statusUpdate =
          status: "Daily osu! Stats Post powered by https://prosu.xyz #ProsuTweetPoster"
          media_ids: media.media_id_string
        # Post the status update
        twitterClient.post 'statuses/update', statusUpdate, (err, tweet) ->
          if err then return done err
          # Push the new status to the history of statuses posted in our database
          user.tweetHistory.push {
            datePosted: Date.now()
            tweetObject: tweet
          }
          # Save our user in the database
          user.save (err) ->
            ## IM NOT SURE HOW TO HANDLE THIS ERROR. LIKE, IF WE CALL AN ERROR HERE,
            ##THE TWEET IS ALREADY POSTED SO IT ISN'T LIKE WE CAN JUST FAIL THE JOB
            ##BECAUSE IT WOULD POST ANOTHER TWEET? GUESS WE JUST HAVE TO HOPE IT WORKS LOL
            #if err then return done err

            # We have finished posting the tweet
            return done()
