module.exports = (app) ->
  (require './home') app
  (require './connect') app
  (require './logout') app
  (require './privacy') app
  (require './404') app
  (require './500') app
