variables = require '../../../util/variables'
path = require 'path'
module.exports = (app) ->
  privacy = (req, res) ->
    res.render (path.join __dirname, "./index.hbs"), {
      title: "Privacy Policy"
      hostname: variables.domain
      user: req.user
      isAuthenticated: req.isAuthenticated()
    }
  app.get '/privacy', privacy
