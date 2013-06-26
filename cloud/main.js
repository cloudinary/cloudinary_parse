cloudinary = require("cloud/cloudinary/all");
_ = require('cloud/cloudinary/lib/underscore')

/* Configuration sample:
    cloudinary.config({
        api_key: 'my_api_key',
        api_secret: 'my_api_secret',
    });
/**/



/**
 * The following declaration exposes a cloud code function that enables you
 * to sign a direct-upload request from your app. 
 * @note This function assumes no extra parameters are needed for the upload.
 * @note This function embeds the username in the cloudinary tags field.
 */
Parse.Cloud.define("sign_upload_request", function(request, response) {
    if (!request.user || !request.user.authenticated()) {
        response.error("Needs an authenticated user");
        return;
    }
    response.success(
        cloudinary.sign_upload_request({tags: request.user.getUsername()})
    );
});

/**
 * This factory creates a beforeSave filter that verifies that a given
 * cloudinary-identifier field in your object is a valid (has correct signature)
 *
 * @note This function allows changing of other fields without validation
 */
function beforeSaveFactory(object_name, field_name) {
    Parse.Cloud.beforeSave(object_name, function(request, response) {
        var identifier = request.object.get(field_name);
        function verify_upload(previous_value) {
            if (identifier === previous_value || cloudinary.verify_upload(identifier)) {
                // Remove signature and store
                request.object.set(field_name, cloudinary.remove_signature(identifier));
                response.success();
            } else {
                response.error("Bad signature");
            }
        }

        (new Parse.Query(object_name)).get(request.object.id, {
            success: function(previous) {
                verify_upload(previous.get(field_name));
            },
            error: function(object, error) {
                if (error.code == Parse.Error.OBJECT_NOT_FOUND) {
                    return verify_upload(new Parse.Object);
                }
                response.error(error);
            }
        });
    });
}

/// The following lines install a beforeSave filter for the given field within the given object
var object_name = "Photo";
var field_name = "cloudinary_identifier";
beforeSaveFactory(object_name, field_name);

