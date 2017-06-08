rollbar = require '../../../util/rollbar'
variables = require '../../../util/variables'
path = require 'path'
module.exports = (app) ->
  app.use (err, req, res, next) ->
    rollbar.handle err
    res.status 500
    res.render (path.join __dirname, "./index.hbs"), {
      title: "Error"
      hostname: variables.domain
      user: req.user
      isAuthenticated: req.isAuthenticated()
    }
