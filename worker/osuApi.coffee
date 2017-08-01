osu = require 'node-osu'
variables = require '../util/variables'
osuApi = new osu.Api variables.osuApiKey, {
  notFoundAsError: false
}
module.exports = osuApi
