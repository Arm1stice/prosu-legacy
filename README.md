# Prosu
Automatically post daily osu! rank and statistic update to Twitter daily!

DEPRECATED
==========
This source code is now deprecated, and has been replaced with [Prosu for Twitter](https://github.com/wcalandro/prosu-twitter)


Running
-------
After running `yarn` or `npm install`, you can run the website with the following command:
```
node index.js web
```
You will also need to run an instance of the worker with this command:
```
node index.js worker
```

Environment Variables
---------------------
You can set the following environment variables:

`MONGODB_URI` **required** - MongoDB Connection URI.  
`DOMAIN` **required** - The domain the website will be access from.  
`NEW_RELIC_LICENSE_KEY` **required** - License key to report to NewRelic APM.  
`OSU_API_KEY` **required** - API key for osu!  
`PAPERTRAIL_ENABLED` (default: false) - Whether to enable Papertrail log connection.  
`PAPERTRAIL_HOST` - The domain to send papertrail logs to.  
`PAPERTRAIL_PORT` - The port to send papertrail logs to.  
`REDIS_URL` **required** - URI for Redis server  
`ROLLBAR_ACCESS_TOKEN` **required** - Access token for Rollbar error reporting.  
`TWITTER_CALLBACK_URL` **reuqired** - URL that twitter should call back to, in the form of https://YOUR_DOMAIN_HERE/connect/twitter/callback  
`TWITTER_CONSUMER_KEY` **required** - Twitter Consumer Public Key  
`TWITTER_CONSUMER_SECRET` **required** - Twitter Consumer Secret Key  
