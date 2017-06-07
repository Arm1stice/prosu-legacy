logger = require '../../util/logger'
module.exports = (mongoose, models) ->
  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  # Schema for the User database object

  userModel = mongoose.model "userModel", (require '../schemas/user')
  logger.debug "Add user model"
  models.userModel = userModel
