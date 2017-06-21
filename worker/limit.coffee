# Ratelimiter for the osu! api
Limiter = require 'ratelimiter'
limit = new Limiter
  id: "osu_api"
  db: (require '../util/redis')
  max: 100 # 100 requests
  duration: 60000 # Per 60 seconds

module.exports = limit
