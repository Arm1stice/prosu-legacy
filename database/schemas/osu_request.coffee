mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
osuRequestSchema = new Schema({
    player:
      type: ObjectId
      ref: 'osuPlayerModel'
    mode: String
    dateChecked: Number
    topPlays: Array
})
module.exports = osuRequestSchema
