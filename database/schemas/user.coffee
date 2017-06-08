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
    default: null
    
  twitter:
    type: twitterSchema
})
module.exports = userSchema
