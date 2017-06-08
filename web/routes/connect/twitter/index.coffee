express = require "express"
module.exports = (app) ->
  router = express.Router()

  (require './callback') router
  (require "./get") router

  app.use '/twitter', router
