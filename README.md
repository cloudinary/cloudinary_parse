# Cloudinary Parse Module
This package contains Cloudinary's Parse Cloud Module.
The cloudinary library provides a mechanism for storing cloudinary credentials, signing upload requests and generating Cloudinary URLs.   

## What is Cloudinary?

Cloudinary is a cloud-based service that provides an end-to-end image management solution including uploads, storage, manipulations, 
optimizations and delivery.

With Cloudinary you can easily upload images to the cloud, automatically perform smart image manipulations without installing any complex software. 
All your images are then seamlessly delivered through a fast CDN, optimized and using industry best practices. 
Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with new and existing web and mobile applications.

## Files

* `cloud/cloudinary.js` - The cloudinary library entrypoint. In order to load cloudinary library you must `require('cloud/cloudinary')` the result of this expression is the cloudinary namespace. See `cloud/main.js` for sample usage.

## Configuration

Supplying cloudinary configuration can be specified either by providing `cloudinary_config.js` in the `cloud` directory, or by directly calling `cloudinary.config` with a configuration object (See comment in `main.js` for sample usage).

## Functions

  * beforeSaveFactory - When given an `object_name` and a `field_name`, creates a beforeSave function that verifies updates to `field_name` are only done with a signed cloudinary identifier.   
     The beforeSave function also removes the signatures when saving to the database.
  * url - builds a cloudinary URL given the image identifier and transformation parameters. As a reference you can check the [nodejs documentation](http://cloudinary.com/documentation/node_image_manipulation)
  * sign_upload_request - created a signed request that can be used to construct an HTML form or passed to Cloudinary front-end libraries to initiate an image upload.

## Usage Example

````
cloudinary = require("cloud/cloudinary");

cloudinary.beforeSaveFactory("Photo", "cloudinaryIdentifier");

Parse.Cloud.define("sign_cloudinary_upload_request", function(request, response) {
    if (!request.user || !request.user.authenticated()) {
        response.error("Needs an authenticated user");
        return;
    }
    response.success(
        cloudinary.sign_upload_request({tags: request.user.getUsername(), eager: {crop: "fill", width: 150, height: 100, gravity: "face"}})
    );
});

````

## Sample project

See the [Cloudinary Parse sample project](https://github.com/cloudinary/cloudinary_parse/edit/master/sample)

# Support

You can [open an issue through GitHub](https://github.com/cloudinary/cloudinary_parse/issues).

Contact us [http://cloudinary.com/contact](http://cloudinary.com/contact)

Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary).

# License
Released under the MIT license.

* [underscore.js](http://underscorejs.org/) is also released under the MIT license.
* [crypto-js](https://code.google.com/p/crypto-js/) is released under the New BSD license.

