require '../customFunctions'
a = require 'async'
tweets = 0
userModel = (require '../database/index').models.userModel
console.log "Getting users....."
userModel.find {}, (err, users) ->
  if err then throw err
  console.log "Got #{users.length} users. Iterating through...."
  a.eachSeries users, (user, cb) ->
    console.log user.tweetHistory
    tweets += user.tweetHistory.length
    console.log "Got a user...."
    cb()
  , ->
    console.log "Done!"
    console.log "Tweets: #{tweets}"
    process.exit 0
