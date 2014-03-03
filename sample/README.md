# Cloudinary Parse Sample Project
This package contains a sample intergration with the Cloudinary Parse Cloud Module.
The cloudinary library provides a mechanism for storing cloudinary credentials, signing upload requests and creating Cloudinary URLs for image thumbnails.   
The sample code includes simple Cloud Functions that signs upload requests for authenticated users and return a Cloudinary URL for an image thumbnail.

## Files

* `cloud/main.js` - The entry point to the sample project. Contains:
   * A sample cloud function (`sign_cloudinary_upload_request`) that returns an object with all required parameters to initiate a direct upload to Cloudinary.   
     The function requires an authenticated Parse user, embeds the username into the tags field and eagerly creates a thumbnail.   
     The returned data can be used to construct an HTML form or passed to Cloudinary front-end libraries to initiate an image upload.
   * Initialize the beforeSave factory (`beforeSaveFactory`), which creates a beforeSave function that verifies updates to `field_name` are only done with a signed cloudinary identifier.   
     The beforeSave function also removes the signatures when saving to the database.
   * A sample cloud function that enables you to get a thumbnail url for Cloudinary of a the Photo entity given its objectId.  

* `cloud/cloudinary_config.js` holds cloudinary configuration as examplified in `cloud/cloudinary_config.js.sample`

## Setup the sample project

* [Signup or login to Parse](https://parse.com/#signup)
* [Create a new app](https://parse.com/apps/new)
* Install the Cloud Code Command Line Tool (See [Cloud Code Guide](https://parse.com/docs/cloud_code_guide#started) for more info)
* Create a new project with `parse new`
* Copy the files in this package to the new project folder
* Copy the files from the Cloudinary Cloud Module to the new project folder
* Create a Cloudinary configuration file (`cloudinary_config.js`)
* Deploy your code using `parse deploy`

You're now ready to go

# Sample usage with cURL
## Signup

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_KEY" \
      -H "Content-Type: application/json" \
      -d '{"username":"MY_USER","password":"MY_PASS"}' \
      https://api.parse.com/1/users

## Login

    curl -X GET \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_KEY" \
      -G \
      --data-urlencode 'username=MY_USER' \
      --data-urlencode 'password=MY_PASS' \
      https://api.parse.com/1/login

Response:

    {
      "username":"MY_USER",
      "createdAt":"2013-04-21T12:55:41.891Z",
      "updatedAt":"2013-04-21T12:55:41.891Z",
      "objectId":"USER_ID",
      "sessionToken":"SESSION_TOKEN"
    }


## Get signature

Use `sessionToken` from login response

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_KEY" \
      -H "X-Parse-Session-Token: SESSION_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{}' \
      https://api.parse.com/1/functions/sign_cloudinary_upload_request

Resposne:

    {
      "result": {
        "timestamp":1366555048,
        "tags":"MY_USER",
        "eager":"c_fill,g_face,h_100,w_150"
        "signature":"CLOUDINARY_SIGNATURE",
        "api_key":"CLOUDINARY_API_KEY"
      }
    }

## Upload image to Cloudinary using obtained signature

Note - Uploading to Cloudinary can be done using Cloudinary's client libraries including the 
[iOS](https://github.com/cloudinary/cloudinary_ios) and [Android](https://github.com/cloudinary/cloudinary_android) SDKs.
Alternatively, with cURL, using the response from `sign_cloudinary_upload_request`:

    curl -X POST \
      -F timestamp=1366555048 \
      -F tags=MY_USER \
      -F signature=CLOUDINARY_SIGNATURE \
      -F api_key="CLOUDINARY_API_KEY" \
      -F file=@sample.jpg \
      http://api.cloudinary.com/v1_1/my_cloud_name/image/upload

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
      "secure_url":"https://res.cloudinary.com/my_cloud_name/image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg"
    }

## Create Photo record using the uploaded image

Using the response from Cloudinary:

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_KEY" \
      -H "X-Parse-Session-Token: SESSION_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"cloudinaryIdentifier":"image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg#CLOUDINARY_RESULT_SIGNATURE"}' \
      https://api.parse.com/1/classes/Photo

Response:

    {
      "cloudinaryIdentifier":"image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg",
      "createdAt":"2013-04-21T15:31:06Z",
      "objectId":"PHOTO_ID"
    }

## Generate a Cloudinary URL of a thumbnail of the Photo

Using the objectId returned when creating the Photo record:

    curl -X POST \
      -H "X-Parse-Application-Id: PARSE_APP_ID" \
      -H "X-Parse-REST-API-Key: PARSE_REST_KEY" \
      -H "X-Parse-Session-Token: SESSION_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"objectId":"PHOTO_ID"}' \
      https://api.parse.com/1/functions/build_cloudinary_url

Response:
    
    {
      "result": {
        "url":"http://res.cloudinary.com/my_cloud_name/image/upload/c_fill,h_100,w_150/v1/image/upload/v1366555348/k3vmeifbepxddbzjuop9.jpg"
      }
    }
