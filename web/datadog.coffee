# Stats tracking sent to DataDog!
metrics = require 'datadog-metrics'
metrics.init {
  host: process.env.HOSTNAME
  prefix: 'prosu.'
}
totalRequests = 0;

module.exports.middleware = (req, res, next) ->
  totalRequests++
  next()

setInterval ->
  metrics.gauge 'web.requests', totalRequests
  totalRequests = 0
, 60000
