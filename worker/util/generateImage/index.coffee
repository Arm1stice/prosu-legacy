fs = require 'fs'
path = require 'path'
maniaImage = fs.readFileSync(path.join __dirname, "../../modes/mania.png")
taikoImage = fs.readFileSync(path.join __dirname, "../../modes/taiko.png")
ctbImage = fs.readFileSync(path.join __dirname, "../../modes/ctb.png")
osuImage = fs.readFileSync(path.join __dirname, "../../modes/osu.png")
guestAvatar = fs.readFileSync(path.join __dirname, "../../modes/avatar-guest.png")
emptyFlag = fs.readFileSync(path.join __dirname, "../../flags/__.png")
logger = require '../../../util/logger'
modeImages = [
  osuImage,
  taikoImage,
  ctbImage,
  maniaImage
]
modes = [
  'standard',
  'taiko',
  'ctb',
  'mania'
]
Canvas = require 'canvas'
request = require 'request'
drawData = require './drawData'
Image = Canvas.Image
module.exports = (osuPlayer, mode, done) ->
  avatarImage = new Image
  modeImage = new Image
  flagImage = new Image

  playerModeChecks = osuPlayer.modes[modes[mode]].checks # The array of checks of the mode that was passed to us
  check = playerModeChecks.last(); # The last object in the checks array

  # If we only have one set of data for some reason, then we just use the current data for both data variables.
  if playerModeChecks.length is 1
    # Set oldData equal to data
    oldCheck = check;
  else
    # Set oldData equal to the index one before
    oldCheck = playerModeChecks[playerModeChecks.length - 2];
  ## LOAD IMAGES INTO VARIABLES
  loadImages = (osuPlayer, mode, data, done) ->
    modeImage.onerror = (error) ->
      throw err
    modeImage.onload = ->
      done()
    flagImage.onerror = (err) ->
      throw err
    flagImage.onload = ->
      switch mode
        when 0
          modeImage.src = osuImage
          break
        when 1
          modeImage.src = taikoImage
          break
        when 2
          modeImage.src = ctbImage
          break
        when 3
          modeImage.src = maniaImage
          break
        else
          done "Something went wrong, the mode isn't being handled correctly"
    avatarImage.onerror = (err) ->
      logger.warn "Error loading profile picture as source. Loading guest avatar. (#{osuPlayer.name})"
      avatarImage.src = guestAvatar
    avatarImage.onload = ->
      fs.readFile (path.join __dirname, "../../flags/#{data.country}.png"), (err, flag) ->
        if err
          logger.error err
          flagImage.src = emptyFlag
        else
          flagImage.src = flag
    request.get {url: "https://a.ppy.sh/#{osuPlayer.userid}", encoding: null}, (error, response, body) ->
      if error then return done err
      if response.statusCode is 404
        avatarImage.src = guestAvatar
      else
        avatarImage.src = body
  ## Now we can actually call the function
  loadImages osuPlayer, mode, check.data, (err) ->
    # Handle error
    if err then return done err
    # Yay, no errors
    canvas = new Canvas 440, 220 # Create new canvas with size of max twitter image size for full preview
    ctx = canvas.getContext '2d' # Get 2d context of canvas

    ## DRAW BACKGROUND RECTANGLE
    ctx.beginPath();
    ctx.rect 0, 0, 440, 220
    ctx.fillStyle = "black"
    ctx.fill()
    ctx.stroke()

    ## DRAW AVATAR IMAGE IN TOP LEFT CORNER
    ctx.drawImage avatarImage, 0, 0, 100, 100

    ## DRAW MODE ON LEFT SIDE
    ctx.drawImage modeImage, 25, 160, 45, 45

    ## DRAW COUNTRY FLAG ON BOTTOM LEFT
    ctx.drawImage flagImage, 25, 115, 45, 30

    ## DRAW INFO REGARDING PLAYER NAME AND STUFF
    ctx.font = '20px Impact' # Set the font
    ctx.fillStyle = 'white' # Set the font color
    ctx.fillText 'Stats For: ', 110, 24 # Write at the TOP
    statsWidth = (ctx.measureText 'Stats For: ').width
    ctx.font = 'bold 20px Impact' # Now use bold font
    ctx.fillText osuPlayer.name, 110 + statsWidth, 24 # Write the player name next to the title text

    ctx.font = '12px Impact' # Set a smaller font
    ctx.fillText "Updated On: " + (new Date(check.dateChecked)).toLocaleDateString(), 110, 40 # Write the time when the data was gathered.

    ctx.strokeStyle = 'white' # Set stroke style to color white
    ctx.beginPath() # Start drawing
    ctx.moveTo 100, 45 # Start line
    ctx.lineTo 440, 45 # Draw line to new cords
    ctx.stroke() # Paint line

    ## DRAW ALL THE DATA
    drawData ctx, check, oldCheck, ->
      return done null, canvas.toBuffer()
