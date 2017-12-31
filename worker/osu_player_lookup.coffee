###
  This file defines the function that will be called when we create a job to look up the profile of an osu! player
###

# osu! api module
osu = require './osuApi'

# ratelimiter object
tryLimit = require './trylimit'

# Logger
logger = require '../util/logger'

# MongoDB User object
osuPlayer = (require '../database/index').models.osuPlayer
osuRequest = (require '../database/index').models.osuRequest
modes = [
  'standard',
  'taiko',
  'ctb',
  'mania'
]
# Our function
module.exports = (queue) ->
  # When we process the job, we are passed two variables, the job object, and a function to call when we complete our task
  queue.process 'osu_player_lookup', (job, done) ->
    # We get the user from the API
    tryLimit (err) ->
      if err
        if err is true
          done "Prosu is currently under load and it is hitting its rate limit with the osu! API. Please try again later"
        else
          done err
      else
        osu.getUser {
          u: job.data.username
          m: job.data.mode
        }
        .then (player) ->
          # The user exists
          if player.id
            logger.debug "Player #{job.data.username} exists"
            # They haven't played the game mode
            if not player.level
              logger.debug "Player #{job.data.username} has never played #{modes[job.data.mode]}"
              return done "It appears that #{job.data.username} has never played that game mode before"
            osuPlayer.findOne {
              userid: player.id
            }
            .populate "modes.#{modes[job.data.mode]}.checks"
            .exec (err, user) ->
              if err
                logger.error "[osu_player_lookup.coffee] An error occured while looking up a player in osuPlayer"
                return done err # If there was a database error, then we immediately return it
              if user # The user already exists in our database
                shouldSaveUser = false
                shouldSaveRequest = false
                request = null
                logger.info "[osu_player_lookup.coffee] User #{player.name} already exists in our database, we have to check on it"
                # We need to check and see if the user's username might have changed since the last time we saved to the db
                if player.name isnt user.name
                  logger.info "[osu_player_lookup.coffee] User with id #{player.id} has an older username, updating it"
                  shouldSaveUser = true
                  user.name = player.name
                checksArray = user.modes[modes[job.data.mode]].checks
                if checksArray.length isnt 0 and (new Date).getTime() - checksArray[checksArray.length - 1].dateChecked > 86400000
                  logger.info "[osu_player_lookup.coffee] It's been more than a day since we last looked up the rank of #{player.name} for mode #{modes[job.data.mode]}. Adding to checks array"
                  request = new osuRequest {
                    player: user._id
                    data: player
                    dateChecked: (new Date).getTime()
                  }
                  checksArray.push request._id
                  shouldSaveRequest = true
                else if checksArray.length is 0
                  logger.info "[osu_player_lookup.coffee] We've never checked the rank on player #{player.name} for mode #{modes[job.data.mode]}. Adding it to database..."
                  request = new osuRequest {
                    player: user._id
                    data: player
                    dateChecked: (new Date).getTime()
                  }
                  checksArray.push request._id
                  shouldSaveRequest = true
                else
                  logger.info "[osu_player_lookup.coffee] We have a recent rank check for #{player.name} under game mode #{modes[job.data.mode]}. No need to do anything"
                  return done null, user._id
                if shouldSaveRequest
                  logger.info "[osu_player_lookup.coffee] We have to save the request for #{player.name}. Doing so...."
                  request.save (err) ->
                    if err then return done "An error occurred while saving the stats request to the database"
                    logger.info "[osu_player_lookup.coffee] Saved the request for user #{player.name}. Saving user to database..."
                    user.save (err) ->
                      logger.info "[osu_player_lookup.coffee] Saved #{player.name} to database. Job #{job.id} completed"
                      if err then return done "An error occurred while saving the new user to the database"
                      return done null, user._id
                else if shouldSaveUser
                  logger.info "[osu_player_lookup.coffee] We need to save #{player.name} to the database. Doing so..."
                  user.save (err) ->
                    if err then return done "An error occurred while saving the new user to the database"
                    logger.info "[osu_player_lookup.coffee] Saved #{player.name} to database. Job #{job.id} completed"
                    return done null, user._id
                else
                  return done null, user._id
              else
                logger.info "[osu_player_lookup.coffee] User doesn't exist in our database, we have to make a new entry"
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
                  newUser.modes[modes[job.data.mode]].checks.push request._id
                  newUser.save (err) ->
                    if err then return done "An error occurred while saving the new user to the database"
                    logger.info "[osu_player_lookup.coffee] Saved #{player.name} to database. Job #{job.id} completed"
                    return done null, newUser._id
          # The user doesn't exist
          else
            done "The user you specified doesn't exist"
        .catch (err) ->
          logger.error "An error occurred"
          logger.error err
          done err, null # Return err, null user
