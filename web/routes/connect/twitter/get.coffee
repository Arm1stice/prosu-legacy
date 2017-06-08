passport = require "passport"
module.exports = (app) ->
  app.use '/', (req, res, next) ->
    if req.isAuthenticated()
      return res.redirect "/"
    else
      return next()
  app.get '/', (passport.authenticate 'twitter')
