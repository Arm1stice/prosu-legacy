variables = require '../../../util/variables'
path = require 'path'
module.exports = (app) ->
  app.use (req, res, next) ->
    res.status 404
    res.render (path.join __dirname, "./index.hbs"), {
      title: "Not Found"
      hostname: variables.domain
      user: req.user
      isAuthenticated: req.isAuthenticated()
    }
