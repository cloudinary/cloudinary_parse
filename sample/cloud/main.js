/* 
 * Sample Cloudinary Parse Cloud Code that uses the Cloudinary Parse Module 
 */ 
cloudinary = require("cloud/cloudinary");

/* 
   Configuration sample:
    cloudinary.config({
        cloud_name: 'my_cloud_name',
        api_key: 'my_api_key',
        api_secret: 'my_api_secret',
    });
 */

/// The following lines install a beforeSave filter for the given field within the given object
var OBJECT_NAME = "Photo";
var CLOUDINARY_IDENTIFIER_FIELD_NAME = "cloudinaryIdentifier";
/// You can either use and modify the example beforeSaveFactory in this file, or use the one from the library:
// beforeSaveFactory(object_name, field_name);
cloudinary.beforeSaveFactory(OBJECT_NAME, CLOUDINARY_IDENTIFIER_FIELD_NAME);

/**
 * The following declaration exposes a cloud code function that enables you
 * to sign a direct-upload request from your app. 
 * @note This function assumes no extra parameters are needed for the upload.
 * @note This function embeds the username in the cloudinary tags field and eagerly creates a thumbnail.
 */
Parse.Cloud.define("sign_cloudinary_upload_request", function(request, response) {
    if (!request.user || !request.user.authenticated()) {
        response.error("Needs an authenticated user");
        return;
    }
    response.success(
        cloudinary.sign_upload_request({tags: request.user.getUsername()})

        // cloudinary.sign_upload_request({tags: request.user.getUsername(), eager: {crop: "fill", width: 150, height: 100, gravity: "face"}})
    );
});

/**
 * The following declaration exposes a cloud code function that enables you to get a 
 * thumbnail url for Cloudinary of a the Photo entity. 
 * Cloud-based image manipulation URLs can also be generated on the mobile apps based 
 * on the identifier returned when uploading a object using the beforeSaveFactory above.
 */
Parse.Cloud.define("photo_thumbnail_url", function(request, response) {
    if (!request.user || !request.user.authenticated()) {
        response.error("Needs an authenticated user");
        return;
    }

    var query = new Parse.Query(OBJECT_NAME);
    query.get(request.params.objectId, {
      success: function(result) {
        response.success({
            url: cloudinary.url(result.get(CLOUDINARY_IDENTIFIER_FIELD_NAME), {crop: "fill", width: 150, height: 100, gravity: "face"})
        });
      },
      error: function() {
        response.error("image lookup failed");
      }
    });
});


