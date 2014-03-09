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

### Installation

Installing the Cloud Module is done by copying all files and folders under [https://github.com/cloudinary/cloudinary_parse/tree/master/cloud](https://github.com/cloudinary/cloudinary_parse/tree/master/cloud) to the `cloud` folder of the specific Cloud Code project that uses the module. In the case of the included sample Cloud Code project, it should be copied to the `cloud` folder of a local copy of: [https://github.com/cloudinary/cloudinary_parse/tree/master/sample](https://github.com/cloudinary/cloudinary_parse/tree/master/sample)


## Configuration

Supplying cloudinary configuration can be specified either by providing `cloudinary_config.js` in the `cloud` directory, or by directly calling `cloudinary.config` with a configuration object (See comment in `sample/cloud/main.js` for sample usage). 

The configuration is based on the Cloud Name, API Key and API Secret credentials of your Cloudinary account. They can be obtained from the dashboard of [Cloudinary's Management Console](https://cloudinary.com/console).

If you haven't done so already, you can [sign-up to a free Cloudinary account](https://cloudinary.com/users/register/free).

## Functions

### sign_upload_request

Creates a signed request that can be used to construct an HTML form or passed to Cloudinary front-end libraries to initiate a secure image upload.

  *  Uploading of images to Cloudinary is performed directly from web or mobile applications. 
  *  In order to initiate an authenticated upload request from the mobile apps, the server-side, Parse in this case, needs to create a signature for securing each upload request. 
  *  The `sign_upload_request` method generates a signature of given upload parameters, including image manipulation ones, using the API Secret parameter of the Cloudinary account.
  
### beforeSaveFactory
When given an `object_name` and a `field_name`, creates a beforeSave function that verifies updates to `field_name` are only done with a signed cloudinary identifier. The beforeSave function also removes the signatures when saving to the database.

  * Images uploaded directly from web and mobile applications are assigned unique Cloudinary identifiers that should be stored in the Parse backend model for any manipulation and displaying using Cloudinary in web and mobile applications. 
  * The `beforeSaveFactory` function allows verifying a given image identifier and storing correctly in a Parse model (database) record.

### url
builds a cloudinary URL given the image identifier and transformation parameters. 
As a reference you can check the [nodejs documentation](http://cloudinary.com/documentation/node_image_manipulation). Alternatively, you can build Cloudinary image manipulation and delivery URLs from your mobile applications.

  * Cloudinary manipulates images on-the-fly and delivers them via a fast CDN using dynamic URLs. 
  * The URLs are based on the identifiers of uploaded image. Usually such URLs are built on the client-side web and mobile applications using the identifiers received from the Parse backend. 
  * However, you might want to generate such URLs on the Parse server side and return them to client apps. 
  * The `url` function takes care of building the image manipulation and delivery URLs. 
  * Below are sample manipulation and delivery URL of a previously uploaded image with the public ID of 'couple':
    * Original image uploaded to Cloudinary: [http://res.cloudinary.com/demo/image/upload/couple.jpg](http://res.cloudinary.com/demo/image/upload/couple.jpg)
    * On-the-fly manipulation URL of a 150x150 face detection based cropped thumbnail to a circular shape with the Sepia effect applied. [http://res.cloudinary.com/demo/image/upload/c_thumb,w_150,h_150,g_faces,r_max,e_sepia/couple.jpg](http://res.cloudinary.com/demo/image/upload/c_thumb,w_150,h_150,g_faces,r_max,e_sepia/couple.jpg)

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

