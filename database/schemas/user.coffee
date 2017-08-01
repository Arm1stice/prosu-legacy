mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

twitterSchema = new Schema({
  profile: Object
  token: String
  tokenSecret: String
})
userSchema = new Schema({
  osuSettings:
    player:
      type: ObjectId
      ref: "osuPlayerModel"
      default: null
    mode:
      type: Number
      default: 0
    enabled:
      type: Boolean
      default: false

  twitter:
    type: twitterSchema
})
module.exports = userSchema
