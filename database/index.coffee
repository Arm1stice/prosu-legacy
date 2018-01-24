variables = require '../util/variables'
logger = require '../util/logger'
rollbar = require '../util/rollbar'
mongoose = require 'mongoose'
mongoose.Promise = global.Promise;
mongoose.connection.openUri variables.mongoURI
db = mongoose.connection
db.once 'open', ->
  logger.debug "Connected to MongoDB Database"
db.on 'error', (err) ->
  rollbar.handle err

module.exports.models = (require './models/index') mongoose
