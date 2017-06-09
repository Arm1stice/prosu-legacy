logger = require '../../util/logger'
module.exports = (mongoose, models) ->
  Schema = mongoose.Schema
  ObjectId = Schema.Types.ObjectId

  osuModel = mongoose.model 'osuRequestModel', (require '../schemas/osu_request')
  models.osuPlayer = osuModel
