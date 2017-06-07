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
app.use require('cookie-parser')()
app.use require('body-parser').urlencoded
    extended: true
app.use require('express-session')
    secret: variables.SESSION_SECRET
    resave: true
    saveUninitialized: true
app.use require('passport').initialize()
app.use require('passport').session()
