passport = require "passport"
module.exports = (app) ->
  app.get '/', (passport.authenticate 'twitter', { failureRedirect: '/', failureFlash: true}), (req, res) ->
    return res.redirect '/'
