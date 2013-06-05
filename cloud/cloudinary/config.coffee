_ = require("cloud/cloudinary/lib/underscore")
cloudinary_config = undefined
module.exports = (new_config, new_value) ->
  if cloudinary_config == undefined || new_config == true
    try
      cloudinary_config = require('cloud/cloudinary_config').config
    catch err
      console.log("Couldn't find configuration file at 'cloud/cloudinary_config.js'")
      cloudinary_config = {}
  if not _.isUndefined(new_value)
    cloudinary_config[new_config] = new_value
  else if _.isString(new_config)
    return cloudinary_config[new_config]
  else if _.isObject(new_config)
    cloudinary_config = new_config
  cloudinary_config

