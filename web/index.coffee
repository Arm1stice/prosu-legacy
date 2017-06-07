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
