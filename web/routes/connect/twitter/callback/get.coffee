passport = require "passport"
module.exports = (app) ->
  app.get '/', (passport.authorize 'twitter', { failureRedirect: '/', failureFlash: true}), (req, res) ->
