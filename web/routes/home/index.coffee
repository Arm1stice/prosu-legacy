variables = require '../../../util/variables'
path = require 'path'
module.exports = (app) ->
  home = (req, res) ->
    res.render (path.join __dirname, "./index.hbs"), {
      title: "Home"
      hostname: variables.domain
      user: req.user
      isAuthenticated: req.isAuthenticated()
    }
  app.get '/', home
