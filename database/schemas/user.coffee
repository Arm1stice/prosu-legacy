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
    mode: Number

  twitter:
    type: twitterSchema
    default: null
})
module.exports = userSchema
