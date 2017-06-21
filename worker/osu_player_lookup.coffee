###
  This file defines the function that will be called when we create a job to look up the profile of an osu! player
###

# osu! api module
osu = require 'node-osu'

# ratelimiter object
tryLimit = require './trylimit'

# Logger
logger = require '../util/logger'

# MongoDB User object
osuPlayer = require('../database/models').osuPlayer

# Our function
module.exports = (queue) ->
  # When we process the job, we are passed two variables, the job object, and a function to call when we complete our task
  queue.process 'osu_player_lookup', (job, done) ->
    # We get the user from the API
    tryLimit (err) ->
      if err
        if err is true
          done "Prosu is currently under load and it hitting its rate limit with the osu! API. Please try again later"
        else
          done err
      else
        osu.getUser {
          u: job.data.username
        }
        .then (player) ->
          # The user exists
          if player
            osuPlayer.findOne {
              userid: player.id
            }, (err, user) ->
              if err
                logger.error "[osu_player_lookup.coffee] An error occured while looking up a player in osuPlayer"
                return done err # If there was a database error, then we immediately return it
              if user # The user already exists in our database
                # We need to check and see if the user's username might have changed since the last time we saved to the db
                if player.name isnt user.name
                  user.name = player.name
                  user.save (err) ->
                    if err
                      logger.error "[osu_player_lookup.coffee] An error occured while saving a change in an osu player's username"
                    else
                      return done null, true # Return no error, and the user is valid
                # We don't need to update the user in the database
                else
                  return done null, true # Return no error, and the user is valid
          # The user doesn't exist
          else
            done null, false # Return no error, but user not found
        .catch (err) ->
          done err, null # Return err, null user
