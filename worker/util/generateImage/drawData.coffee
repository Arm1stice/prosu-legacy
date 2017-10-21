###
  Draw all the info for all the statistics
###

types = [
  {name: 'pp.rank', text: "Rank: "},
  {name: 'pp.countryRank', text: "Country Rank: "},
  {name: 'pp.raw', text: "PP: "},
  {name: 'counts.plays', text: "Play Count: "},
  {name: 'level', text: "Level: "},
  {name: 'accuracy', text: "Accuracy: "},
  {name: 'counts.SS', text: "SS: "},
  {name: 'counts.S', text: "S: "},
  {name: 'counts.A', text: "A: "}
]
_ = require 'lodash'
triangleColor = [
  'red',
  'gray',
  'green'
]
oppositeTriangleColor = [
  'green',
  'gray',
  'red'
]
module.exports = (ctx, newCheck, oldCheck, done) ->
  # Holds object for each type containing: The new value, the difference between the two, and either 0, 1 ,or 2 (0 bad, 1 same, 2 for good)
  winnerData = {}
  # Value for current vertical pixels
  eax = 63
  # UTILITY FUNCTIONS
  findDifferences = (done) ->
    checkWinner type.name for type in types
    done()
  drawData = (type) ->
    ctx.fillStyle = 'white'
    ctx.font = '18px Impact'

    typeOfData = type.name
    ## First, we figure out what text to write and measure it
    textToWrite = ""
    textWidth = 0
    # If the type of data is accuracy, we need to round the percentage
    if typeOfData is "accuracy"
      textToWrite = type.text + Math.round10(Number(winnerData[typeOfData].value), -2).toLocaleString() + "%"
    else
      textToWrite = type.text + Number(winnerData[typeOfData].value).toLocaleString()
    textWidth = (ctx.measureText textToWrite).width

    ## Now, we can write the text
    ctx.fillText textToWrite, 110, eax

    ## Now that the text is written, we can draw the triangle
    if typeOfData is "pp.rank" or typeOfData is "pp.countryRank"
      ctx.fillStyle = oppositeTriangleColor[winnerData[typeOfData].good]
      ctx.strokeStyle = oppositeTriangleColor[winnerData[typeOfData].good]
    else
      ctx.fillStyle = triangleColor[winnerData[typeOfData].good]
      ctx.strokeStyle = triangleColor[winnerData[typeOfData].good]
    ctx.beginPath()
    if winnerData[typeOfData].good is 0 # Red triangle
      ctx.moveTo 110 + textWidth + 5, (eax - 8.5) # Start at the left side of the top of the triangle
      ctx.lineTo 110 + textWidth + 20, (eax - 8.5) # Go 15 px right
      ctx.lineTo 110 + textWidth + 12.5, eax # Go to meeting point
      ctx.fill()
      ctx.fillText winnerData[typeOfData].change, (110 + textWidth + 22), eax
    else if winnerData[typeOfData].good is 1 # Gray triangle
      ctx.moveTo 110 + textWidth + 5, (eax - 5.5) # Start at the left side of the top of the triangle
      ctx.lineTo 110 + textWidth + 20, (eax - 5.5) # Go 15 px right
      ctx.lineTo 110 + textWidth + 12.5, (eax - 13) # Go to meeting point
      ctx.fill()
      ctx.beginPath()
      ctx.moveTo 110 + textWidth + 5, (eax - 5.5) # Start at the left side of the top of the triangle
      ctx.lineTo 110 + textWidth + 20, (eax - 5.5) # Go 15 px right
      ctx.lineTo 110 + textWidth + 12.5, (eax + 2) # Go to meeting point
      ctx.fill()
      ctx.fillText winnerData[typeOfData].change, (110 + textWidth + 25), eax
    else # Green triangle
      ctx.moveTo 110 + textWidth + 5, (eax - 2.5) # Start at the left side of the top of the triangle
      ctx.lineTo 110 + textWidth + 20, (eax - 2.5) # Go 15 px right
      ctx.lineTo 110 + textWidth + 12.5, (eax - 11)# Go to meeting point
      ctx.fill()
      ctx.fillText winnerData[typeOfData].change, (110 + textWidth + 20), eax
    eax += 18
  checkWinner = (type) ->
    winnerData[type] = {}
    winnerData[type].value = _.get(newCheck.data, type)
    winnerData[type].change = Math.abs(Number(_.get(newCheck.data, type)) - Number(_.get(oldCheck.data, type)))
    if type is 'accuracy' or type is 'level'
      winnerData[type].change = Math.round10(winnerData[type].change, -2)
    if Number(_.get(newCheck.data, type)) > Number(_.get(oldCheck.data, type))
      winnerData[type].good = 2
    else if Number(_.get(newCheck.data, type)) is Number(_.get(oldCheck.data, type))
      winnerData[type].good = 1
    else
      winnerData[type].good = 0
  # First we find the differences between the two checks
  findDifferences ->
    # Now we have the differences, so we can start drawing!
    drawData type for type in types
    return done()
