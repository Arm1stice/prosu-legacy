express = require 'express'
module.exports = (app) ->
  router = express.Router()
  (require "./get") router
  app.use '/callback', router
