# Cloudinary Parse Module
This package contains Cloudinary's integration pack for Parse Cloud Code.
The cloudinary library provides a mechanism for storing cloudinary credentials and signing upload requests.   
Also provided in this package is sample code of a simple Cloud Function that signs upload requests for authenticated users.

## Files

* `cloud/main.js` - The main cloud code file loaded by parse. Contains:
   * A sample cloud function (`sign_upload_request`) that returns an object with all required parameters to initiate a direct upload to cloudinary.   
     The function requires an authenticated Parse user and embeds the username into the tags field.   
     The returned data can be used to construct an HTML form or passed to cloudinary front-end libraries to initiate an image upload.
   * A sample beforeSave factory (`beforeSaveFactory`). When given an `object_name` and a `field_name`, creates a beforeSave function that verifies updates to `field_name` are only done with a signed cloudinary identifier.   
     The beforeSave function also removes the signatures when saving to the database.
* `cloud/cloudinary.js` - The cloudinary library entrypoint. In order to load cloudinary library you must `require('cloud/cloudinary')` the result of this expression is the cloudinary namespace. See `cloud/main.js` for sample usage.
* `cloud/cloudinary_config.js` holds cloudinary configuration as demonstrated in `cloud/cloudinary_config.js.sample`

## Setup the sample project

* [Signup or login to Parse](https://parse.com/#signup)
* [Create a new app](https://parse.com/apps/new)
* Install the Cloud Code Command Line Tool (See [Cloud Code Guide](https://parse.com/docs/cloud_code_guide#started) for more info)
* Create a new project with `parse new`
* Copy the files in this package to the new project folder
* Create cloudinary configuration file (`cloudinary_config.js`)
* Deploy your code `parse deploy`

You're now ready to go

## Configuration
Supplying cloudinary configuration can be specified either by providing `cloudinary_config.js` in the `cloud` directory, or by directly calling `cloudinary.config` with a configuration object (See comment in `main.js` for sample usage).

# Sample usage with cURL
## Signup

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"username":"MY_USER","password":"MY_PASS"}' \
      https://api.parse.com/1/users

## Login

    curl -X GET \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_API_KEY" \
      -G \
      --data-urlencode 'username=MY_USER' \
      --data-urlencode 'password=MY_PASS' \
      https://api.parse.com/1/login

Response:

    {
      "username":"MY_USER",
      "createdAt":"2013-04-21T12:55:41.891Z",
      "updatedAt":"2013-04-21T12:55:41.891Z",
      "objectId":"JovCXZZxk7",
      "sessionToken":"SESSION-TOKEN"
    }


## Get signature

Use `sessionToken` from login response

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_API_KEY" \
      -H "X-Parse-Session-Token: SESSION-TOKEN" \
      -H "Content-Type: application/json" \
      -d '{}' \
      https://api.parse.com/1/functions/sign_upload_request

Resposne:

    {
      "result": {
        "timestamp":1366555048,
        "tags":"MY_USER",
        "signature":"CLOUDINARY_SIGNATURE",
        "api_key":"CLOUDINARY_API_KEY"
      }
    }

## Upload image to Cloudinary using obtained signature

Using the response from `sign_upload_request`:

    curl -X POST \
      -F timestamp=1366555048 \
      -F tags=MY_USER \
      -F signature=CLOUDINARY_SIGNATURE \
      -F api_key="CLOUDINARY_API_KEY" \
      -F file=@MY_IMAGE.jpg \
      http://api.cloudinary.com/v1_1/MY_CLOUD_NAME/image/upload

Response:

    {
      "public_id":"k3vmeifbepxddbzjuop9",
      "version":1366555348,
      "signature":"CLOUDINARY_RESULT_SIGNATURE",
      "width":453,
      "height":604,
      "format":"jpg",
      "resource_type":"image",
      "created_at":"2013-04-21T15:31:06Z",
      "tags":["MY_USER"],
      "bytes":52534,
      "type":"upload",
      "url":"http://res.cloudinary.com/my_cloud_name/image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg",
      "secure_url":"https://cloudinary-a.akamaihd.net/my_cloud_name/image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg"
    }

# Support

You can [open an issue through GitHub](https://github.com/cloudinary/cloudinary_parse/issues).

Contact us at [info@cloudinary.com](mailto:info@cloudinary.com)

Or via Twitter: [@cloudinary](https://twitter.com/#!/cloudinary)

# License
Released under the MIT license.

* [underscore.js](http://underscorejs.org/) is also released under the MIT license.
* [crypto-js](https://code.google.com/p/crypto-js/) is released under the New BSD license.

