express = require 'express'
passport = require 'passport'
handle = (require '../../../util/rollbar').handle
variables = require '../../../util/variables'
twitterStrategy = (require 'passport-twitter').Strategy

models = (require '../../../database/index').models
userModel = models.userModel

module.exports = (app) ->
  router = express.Router()
  passport.use new twitterStrategy {
    consumerKey: variables.twitterConsumerKey
    consumerSecret: variables.twitterConsumerSecret
    callbackURL: variables.twitterCallbackURL
  }, (token, tokenSecret, profile, done) ->
    userModel.findOne { "twitter.profile.id": profile.id }, (err, user) ->
      # Handle the error if there is one
      if err
        handle err
        done err, null
      # If there isn't an error
      else
        # If we find a user, log that user in
        if user
          done null, user
        # If not, we're gonna try to register them
        else
          user = new userModel {
            twitter:
              profile: profile
              token: token
              tokenSecret: tokenSecret
          }
          # Save the new user
          user.save (err) ->
            # If there is an error, handle and return
            if err
              handle err
              done err, null
            # If there isn't an error, return the newly created user
            else
              done null, user
  (require './twitter') router

  app.use '/connect', router
