mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
osuRequestSchema = new Schema({
    player:
      type: ObjectId
      ref: 'osuPlayerModel'
    dateChecked: Number
    data: Object
})
module.exports = osuRequestSchema
