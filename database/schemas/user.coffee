mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
userSchema = new Schema({
  username: String
  email: String,
  accountLevel: Number,
  accountVerified: Boolean,
  passwordHash: String,
  friends: [{
    friendSince: Number,
    friend: {
      type: ObjectId,
      ref: 'userModel'
    }
  }],
  twitter:
    type: Object
    default: null
  twitterOnly: Boolean
  enterBasicInfo:
    type: Boolean
    default: false
})
module.exports = userSchema
