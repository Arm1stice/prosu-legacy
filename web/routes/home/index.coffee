variables = require '../../../util/variables'
path = require 'path'
userModel = require('../../../database/index').models.userModel
module.exports = (app) ->
  home = (req, res, next) ->
    modes = [
      {
        name: "osu!standard"
      },
      {
        name: "osu!taiko"
      },
      {
        name: "osu!catch"
      },
      {
        name: "osu!mania"
      }
    ]
    error = req.flash 'error'
    success = req.flash 'success'
    # By default, load the home page
    pageToRender = 'index.hbs'
    if req.isAuthenticated()
      if req.user.osuSettings.enabled is true
        pageToRender = 'logged_in_prosu_enabled.hbs'
      else
        pageToRender = 'logged_in_prosu_disabled.hbs'
      # If they have previously saved settings, we want to get them from the database and render them to the user
      if req.user.osuSettings.player isnt null
        userModel.populate req.user, {path: 'osuSettings.player'}, (err, user) ->
          if err
            return next err
          else
            chosenMode = user.osuSettings.mode
            modes[chosenMode].selected = true
            res.render (path.join __dirname, pageToRender), {
              title: "Prosu"
              hostname: variables.domain
              user: req.user
              isAuthenticated: req.isAuthenticated()
              modes: modes
              inputSettings: user.osuSettings
              error: error
              success: success
            }
      else
        res.render (path.join __dirname, pageToRender), {
          title: "Prosu"
          hostname: variables.domain
          user: req.user
          isAuthenticated: req.isAuthenticated()
          modes: modes
          inputSettings: null
          error: error
          sucess: success
        }
    # If not, we send the template a null value
    else
      res.render (path.join __dirname, './index.hbs'), {
        title: "Prosu"
        hostname: variables.domain
        user: req.user
        isAuthenticated: req.isAuthenticated()
        inputSettings: null
        error: error
        success: success
      }
  app.get '/', home
