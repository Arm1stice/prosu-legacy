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
        ref: 'osuPlayerRequest'
    }]
    mania:
      checks: [{
        type: ObjectId
        ref: 'osuPlayerRequest'
      }]
    taiko:
      checks: [{
        type: ObjectId
        ref: 'osuPlayerRequest'
      }]
    ctb:
      checks: [{
        type: ObjectId
        ref: 'osuPlayerRequest'
      }]
})
module.exports = osuPlayerSchema
