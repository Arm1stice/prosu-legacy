# An object of models
models = {}

module.exports = (mongoose) ->
  # Call the exported function of each model file which will add the model to the object
  (require './user') mongoose, models
  (require './confirm') mongoose, models
  (require './osu_player') mongoose, models
  (require './osu_request') mongoose, models
  return models
