# Cloudinary Parse Module

## What is Cloudinary?

Cloudinary is a cloud-based service that provides an end-to-end image management solution including uploads, storage, manipulations, optimizations and delivery.

With Cloudinary you can easily upload images to the cloud, automatically perform smart image manipulations without installing any complex software. 
All your images are then seamlessly delivered through a fast CDN, optimized and using industry best practices. 
Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with new and existing web and mobile applications.

## About the Cloudinary Parse Module

The Cloudinary Parse Module simplifies the integration of your Parse based applications with the Cloudinary service. The module allows you to use Cloudinary's rich set of cloud-based image management features. Securely upload images to the cloud directly from your mobile apps. The image identifiers are automatically assigned to your Parse backend model. 

The image identifiers can then be used to easily deliver your images responsively to your mobile users while applying any of Cloudinary's image manipulation capabilities, including smart cropping, various image effects, watermarks, overlays and many others.


## Files

* `cloud/cloudinary.js` - The cloudinary library entrypoint. In order to load cloudinary library you must `require('cloud/cloudinary')` the result of this expression is the cloudinary namespace. See `sample/cloud/main.js` for sample usage.

## Configuration

Supplying cloudinary configuration can be specified either by providing `cloudinary_config.js` in the `cloud` directory, or by directly calling `cloudinary.config` with a configuration object (See comment in `sample/cloud/main.js` for sample usage). 

The configuration is based on the Cloud Name, API Key and API Secret credentials of your Cloudinary account. They can be obtained from the dashboard of [Cloudinary's Management Console](https://cloudinary.com/console).

If you haven't done so already, you can [sign-up to a free Cloudinary account](https://cloudinary.com/users/register/free).

## Functions

  * `beforeSaveFactory` - When given an `object_name` and a `field_name`, creates a beforeSave function that verifies updates to `field_name` are only done with a signed cloudinary identifier.   
     The beforeSave function also removes the signatures when saving to the database.
  * `url` - builds a cloudinary URL given the image identifier and transformation parameters. As a reference you can check the [nodejs documentation](http://cloudinary.com/documentation/node_image_manipulation). Alternatively, you can build Cloudinary image manipulation and delivery URLs from your mobile applications.
  * `sign_upload_request` - creates a signed request that can be used to construct an HTML form or passed to Cloudinary front-end libraries to initiate a secure image upload.

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

## Sample projects

See [Cloudinary's sample Parse Cloud Code project](https://github.com/cloudinary/cloudinary_parse/tree/master/sample)

See [Cloudinary's sample Android application](https://github.com/cloudinary/cloudinary_android_parse_sample) that uses Cloudinary's Parse Cloud Module through the sample Parse Cloud Code mentioned above.

## Additional resources

Additional resources are available at:

* [Website](http://cloudinary.com)
* [Image transformations documentation](http://cloudinary.com/documentation/image_transformations)
* [Documentation](http://cloudinary.com/documentation)
* [Knowledge Base](http://support.cloudinary.com/forums)
* [iOS SDK](https://github.com/cloudinary/cloudinary_ios)
* [Android SDK](https://github.com/cloudinary/cloudinary_android)

## Support

You can [open an issue through GitHub](https://github.com/cloudinary/cloudinary_parse/issues).

Contact us [http://cloudinary.com/contact](http://cloudinary.com/contact)

Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary).


# License
Released under the MIT license.

* [underscore.js](http://underscorejs.org/) is also released under the MIT license.
* [crypto-js](https://code.google.com/p/crypto-js/) is released under the New BSD license.

