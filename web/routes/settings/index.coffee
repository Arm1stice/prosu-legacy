queue = require '../../../util/queue'
module.exports = (app) ->
  settings = (req, res, next) ->
    if not req.isAuthenticated() then return res.redirect '/'
    if not req.body.osu_username
      req.flash 'error', 'Please fill out the username field'
      return res.redirect '/'
    if not req.body.game_mode
      req.flash 'error', 'Please select a valid game mode'
      return res.redirect '/'
    if req.body.game_mode < 0 || req.body.game_mode > 3
      req.flash 'error', 'Please select a valid game mode'
      return res.redirect '/'
    req.body.game_mode = Number req.body.game_mode
    job = queue.create 'osu_player_lookup', {
      username: req.body.osu_username
      mode: req.body.game_mode
    }
    .removeOnComplete true
    .save()
    job.on 'complete', (result) ->
      req.user.osuSettings.player = result
      req.user.osuSettings.mode = req.body.game_mode
      req.user.save (err) ->
        if err then next err
        req.flash 'success', "Settings saved!"
        return res.redirect '/'
    .on 'failed', (errorMessage) ->
      req.flash 'error', errorMessage
      return res.redirect '/'
  app.post '/settings', settings
