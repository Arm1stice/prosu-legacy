# Domain Environment Variable
domain = if process.env.DOMAIN then process.env.DOMAIN else "127.0.0.1"
module.exports.domain = domain
# Port
port = if process.env.PORT then process.env.PORT else 8080
module.exports.port = port
# NewRelic Key
newRelicKey = if process.env.NEW_RELIC_LICENSE_KEY then process.env.NEW_RELIC_LICENSE_KEY else null
module.exports.newRelicKey = newRelicKey
# Rollbar API Key
rollbarAPI = if process.env.ROLLBAR_ACCESS_TOKEN then process.env.ROLLBAR_ACCESS_TOKEN else null
module.exports.rollbarAPI = rollbarAPI
# Rollbar Endpoint
rollbarEndpoint = if process.env.ROLLBAR_ENDPOINT then process.env.ROLLBAR_ENDPOINT else null
module.exports.rollbarEndpoint = rollbarEndpoint
# MongoDB URI
mongoURI = if process.env.MONGODB_URI then process.env.MONGODB_URI else 'mongodb://localhost/test'
module.exports.mongoURI = mongoURI
# CI Mode
ciMode = if process.env.NODE_ENV is "circle" or process.argv[2] is "ci" then yes else no
module.exports.ciMode = ciMode
# Session Secret
sessionSecret = if process.env.SESSION_SECRET then process.env.SESSION_SECRET else ((require 'crypto').randomBytes 64).toString 'hex'
module.exports.sessionSecret = sessionSecret
# Environment
environment = if process.env.NODE_ENV then process.env.NODE_ENV else "development"
module.exports.environment = environment
# Let's Encrypt
le = if process.env.LETS_ENCRYPT then process.env.LETS_ENCRYPT else false
module.exports.le = le
# Let's Encrypt Path
le_p = if process.env.LETS_ENCRYPT_PATH then process.env.LETS_ENCRYPT_PATH else false
module.exports.le_p = le_p
# Let's Encrypt Return
le_r = if process.env.LETS_ENCRYPT_RETURN then process.env.LETS_ENCRYPT_RETURN else false
module.exports.le_r = le_r
# Twitter Consumer Key
twitter_consumer_key = if process.env.TWITTER_CONSUMER_KEY then process.env.TWITTER_CONSUMER_KEY else false
module.exports.twitterConsumerKey = twitter_consumer_key
# Twitter Consumer Secret
twitter_consumer_secret = if process.env.TWITTER_CONSUMER_SECRET then process.env.TWITTER_CONSUMER_SECRET else false
module.exports.twitterConsumerSecret = twitter_consumer_secret
# Twitter Callback Connect URL
twitter_callback_url = if process.env.TWITTER_CALLBACK_URL then process.env.TWITTER_CALLBACK_URL else "#{domain}/connect/twitter/callback"
module.exports.twitterCallbackURL = twitter_callback_url
# Osu API Key
osu_api_key = if process.env.OSU_API_KEY then process.env.OSU_API_KEY else false
module.exports.osuApiKey = osu_api_key
# Redis URL
redis_url = if process.env.REDIS_URL then process.env.REDIS_URL else 'redis://localhost'
module.exports.redisUrl = redis_url
# Datadog API Key
datadog_api_key = if process.env.DATADOG_API_KEY then process.env.DATADOG_API_KEY else null
module.exports.datadogApiKey = datadog_api_key
