logger = require '../../../util/logger'
module.exports = (app) ->
  app.get '/logout', (req, res) ->
    if req.isAuthenticated()
      req.logout()
    res.redirect '/'
