# Stats tracking sent to DataDog!
variables = require '../util/variables'
metrics = require 'dogapi'
metrics.initialize {
  api_key: variables.datadogApiKey
}
totalRequests = 0;

module.exports.middleware = (req, res, next) ->
  totalRequests++
  next()

setInterval ->
  metrics.metric.send 'web.requests', totalRequests
  totalRequests = 0
, 60000
