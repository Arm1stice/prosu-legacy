osuPlayer = (require '../database').models.osuPlayer
osuRequest = (require '../database').models.osuRequest
osuPlayer.findOne({name: "Arm1stice"}).populate('modes.mania.checks').exec (err, player) ->
  check = {
    player: player._id,
    data: {
      events: [],
      accuracy: '94.7502670288086',
      level: '67.5',
      country: 'US',
      pp: { countryRank: '958', rank: '13476', raw: '3546.69' },
      scores: { total: '2027758980', ranked: '573225781' },
      counts: {
        '50': '24357',
        '100': '546954',
        '300': '2727361',
        plays: '5247',
        A: '284',
        S: '295',
        SS: '2' },
      name: 'Arm1stice',
      id: '6098178'
    },
    dateChecked: 1506631550640
  }
  request = new osuRequest check
  request.save (err) ->
    player.modes.mania.checks.push(request._id)
    player.save (err) ->
      if err then throw err
      process.exit 0
