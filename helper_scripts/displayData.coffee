require '../customFunctions'
osuPlayer = (require '../database/index').models.osuPlayer
osuPlayer.findOne({name: "Arm1stice"}).populate('modes.mania.checks').exec (err, player) ->
  console.log player.userid
  console.log player.modes['mania'].checks.last()
  process.exit 0
