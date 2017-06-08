###
    This is the web process, where all the web magic happens!
###

# Setup error reporting
require('../util/rollbar').setup()

# Import express, our web server, and create an instance of it, which is our web server process
express = require 'express'
app = express()

# Application-wide variables
variables = require '../utils/variables'

# This is where we import all of our middleware
app.use require('cookie-parser')() # The module that parses our cookies

app.use require('body-parser').urlencoded # The module that parses POSTed body data
    extended: true

app.use require('express-session') # The module that handles all of our sessions
    secret: variables.SESSION_SECRET
    store: if variables.environment is "production" then require('connect-redis') { url: variables.redisUrl } else null
    resave: true
    saveUninitialized: true

app.use require('passport').initialize() # Initializes the passport module
app.use require('passport').session() # Initializes passport sessions

if variables.environment is "production" or variables.environment is "staging" # If we are actually running the code on the cluster, we are going to want to force SSL
  app.use require('express-sslify').HTTPS { trustProtoHeader: true }

# This is where we setup Handlebars, our templating engine
hbs = require 'hbs'
hbs.registerPartials (require 'path').join __dirname, "partials"
app.set 'view engine', 'hbs'
app.engine 'hbs', hbs.__express

# Here, we connect our static content to express
app.use express.static require('path').join __dirname, "static"

# All of our routes are handled in routes/ so this is where we call the function to set those up
(require './routes/index') app

# Finally, we can open our server to the world!
app.listen variables.port, (err) ->
  if err then throw err
