mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
osuPlayerSchema = new Schema({
  userid: Number
  name: String
  lastChecked: Number
  modes:
    standard:
      checks: [{
        type: ObjectId
        ref: 'osuRequestModel'
      }]
    mania:
      checks: [{
        type: ObjectId
        ref: 'osuRequestModel'
      }]
    taiko:
      checks: [{
        type: ObjectId
        ref: 'osuRequestModel'
      }]
    ctb:
      checks: [{
        type: ObjectId
        ref: 'osuRequestModel'
      }]
}, { usePushEach: true })
module.exports = osuPlayerSchema
