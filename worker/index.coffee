# Ok, this is our Kue queue, which will handle how jobs are handled by our workers
queue = require('../util/queue')

# Import the logger
logger = require('../util/logger')

# Rollbar
handle = require('../util/rollbar').handle

# Variables
variables = require '../util/variables'

# Redis client
client = require '../util/redis'

# Ratelimiter for the osu! api
Limiter = require 'ratelimiter'
limit = new Limiter
  id: "osu_api"
  db: client
  max: 100 # 100 requests
  duration: 60000 # Per 60 seconds
