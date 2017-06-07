logger = require '../../util/logger'
module.exports = (mongoose, models) ->
  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  confirmModel = mongoose.model 'confirmModel', (require '../schemas/confirm')
  logger.debug "Added user confirmation model"
  models.confirmModel = confirmModel
