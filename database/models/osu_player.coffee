logger = require '../../util/logger'
module.exports = (mongoose, models) ->
  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  osuModel = mongoose.model 'osuPlayerModel', (require '../schemas/osu_player')
  logger.debug "Added osu! player model"
  models.osuPlayer = osuModel
