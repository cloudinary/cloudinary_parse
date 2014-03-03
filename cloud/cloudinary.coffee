GLOBAL = Parse.Cloudinary ?= {}
GLOBAL.get_cloudinary_path = ->
    return GLOBAL.PREFIX if GLOBAL.PREFIX?
    prefixes = ['cloud', '']
    cloudinary_path = "cloudinary"
    require_test_file = "version"

    for prefix in prefixes
        try
            require [prefix, cloudinary_path, require_test_file].join("/")
            GLOBAL.PREFIX = [prefix, cloudinary_path, ""].join("/")
            return GLOBAL.PREFIX
        catch e
            throw e unless e.message.match(/Module \S+ not found/)
    throw new Error("Couldn't find cloudinary in: " + prefices.join(", "))

GLOBAL.require = (file) ->
    path = GLOBAL.get_cloudinary_path()
    require path + file

_ = GLOBAL.require 'lib/underscore.js'

_.extend exports, GLOBAL.require('core.js')
exports.config = GLOBAL.require('config.js')
exports.initialize = (cloud_name, api_key, api_secret) ->
    exports.config(cloud_name: cloud_name, api_key: api_key, api_secret: api_secret)
exports.version = Parse.Cloudinary.VERSION

###
  This factory creates a beforeSave filter that verifies that a given
  cloudinaryIdentifier field in your object is a valid (has correct signature)

  @note This function allows changing of other fields without validation
###
exports.beforeSaveFactory = (object_name, field_name) ->
    Parse.Cloud.beforeSave object_name, (request, response) ->
        verify_upload = (previous_value) ->
            if identifier is previous_value or exports.verify_upload(identifier)
                
                # Remove signature and store
                request.object.set field_name, exports.remove_signature(identifier)
                response.success()
            else
                response.error "Bad signature"
        identifier = request.object.get(field_name)
        (new Parse.Query(object_name)).get request.object.id,
            success: (previous) ->
                verify_upload previous.get(field_name)

            error: (object, error) ->
                return verify_upload(new Parse.Object)  if error.code is Parse.Error.OBJECT_NOT_FOUND
                response.error error
