# A function to try to obtain a limit token and perform a function when having done so
limiter = require './limit'
logger = require '../util/logger'

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
module.exports = tryLimit
