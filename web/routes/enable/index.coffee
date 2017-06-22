module.exports = (app) ->
  enable = (req, res, next) ->
    # Check to see if the user is authenticated. If they aren't then we redirect to the home page
    if req.isAuthenticated()
      # If tweet posting is already enabled, then we don't need to do anything
      if req.user.osuSettings.enabled is true
        return res.redirect '/'
      else
        # Enable tweet posting
        req.user.osuSettings.enabled = true
        # Save the user record
        req.user.save (err) ->
          # If there was an error, pass it to the error handler and send them to the 500 page, otherwise redirect to home
          if err
            return next err
          else
            return res.redirect '/'
    else
      return res.redirect '/'
  app.post '/enable', enable
