cloudinary = require("cloud/cloudinary/all");

/* Configuration sample:
    cloudinary.config({
        api_key: 'my_api_key',
        api_secret: 'my_api_secret',
    });
/**/

Parse.Cloud.define("sign_upload_request", function(request, response) {
    if (!request.user || !request.user.authenticated()) {
        response.error("Needs an authenticated user");
        return;
    }
    response.success(
        cloudinary.sign_upload_request({tags: request.user.getUsername()})
    );
});
