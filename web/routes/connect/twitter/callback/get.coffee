passport = require "passport"
module.exports = (app) ->
  app.get '/', (passport.authenticate 'twitter', { failueRedirect: '/', failureFlash: true}), (req, res) ->
    res.redirect '/'
