variables = require '../../../util/variables'
path = require 'path'
module.exports = (app) ->
  home = (req, res) ->
    # By default, load the home page
    pageToRender = './index.hbs'
    if req.isAuthenticated()
      if req.user.osuSettings.enabled is true
        pageToRender = './logged_in_prosu_enabled.hbs'
      else
        pageToRender = './logged_in_prosu_disabled.hbs'
    res.render (path.join __dirname, pageToRender), {
      title: "Prosu"
      hostname: variables.domain
      user: req.user
      isAuthenticated: req.isAuthenticated()
    }
  app.get '/', home
