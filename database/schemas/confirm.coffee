mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
confirmSchema = new Schema({
    expires: Number
    user:
      type: ObjectId
      ref: 'userModel'
    confirmed: Boolean
    lastResent:
      type: Number
      default: null
}, { usePushEach: true })
module.exports = confirmSchema
