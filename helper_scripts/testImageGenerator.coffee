require('../customFunctions')
osuPlayer = (require '../database/index').models.osuPlayer
generateImage = require '../worker/util/generateImage/index'
checkOld = {
  _id: '59cd5f7e211282348275f4f4',
  player: '59cd5f7e211282348275f4f3',
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
  dateChecked: 1506631550640,
  __v: 0
}
checkNew = {
  _id: '59cd5f7e211282348275f4f4',
  player: '59cd5f7e211282348275f4f3',
  data: {
    events: [],
    accuracy: '99',
    level: '70.5',
    country: 'US',
    pp: { countryRank: '700', rank: '15476', raw: '3546.69' },
    scores: { total: '2027758980', ranked: '573225781' },
    counts: {
      '50': '24357',
      '100': '546954',
      '300': '2727361',
      plays: '6000',
      A: '279',
      S: '295',
      SS: '3' },
    name: 'Arm1stice',
    id: '6098178'
  },
  dateChecked: 1506631550640,
  __v: 0
}
osuPlayer.findOne({name: "Arm1stice"}).populate('modes.mania.checks').exec (err, player) ->
  if err then throw err
  player.modes.mania.checks = [checkOld, checkNew]
  generateImage player, 3, (err, image) ->
    console.log 'done generating image'
    if err then throw err
    base64data = new Buffer(image).toString('base64')
    console.log base64data
    process.exit 0
