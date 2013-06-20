_ = require('cloud/cloudinary/lib/underscore')
sha1 = require('cloud/cloudinary/lib/crypto/sha1')
config = require('cloud/cloudinary/config.js')

exports.sign_upload_request = (params) ->
  params = build_upload_params(params)
  for k, v of params when not present(v)
    delete params[k]

  api_secret = config().api_secret
  if !api_secret?
    throw "Must supply api_secret"
  params.signature = api_sign_request(params, api_secret)
  params.api_key = config().api_key
  if !params.api_key?
    throw "Must supply api_key"

  return params

get_api_url = (action = 'upload', options = {}) ->
  cloudinary = options["upload_prefix"] ? config().upload_prefix ? "https://api.cloudinary.com"
  cloud_name = options["cloud_name"] ? config().cloud_name ? throw("Must supply cloud_name")
  resource_type = options["resource_type"] ? "image"
  return [cloudinary, "v1_1", cloud_name, resource_type, action].join("/")

api_sign_request = (params_to_sign, api_secret) ->
  to_sign = _.sortBy("#{k}=#{build_array(v).join(",")}" for k, v of params_to_sign when v, _.identity).join("&")
  sha1.hex_sha1(to_sign + api_secret)

build_eager = (transformations) ->
  (for transformation in build_array(transformations)
    transformation = _.clone(transformation)
    _.filter([generate_transformation_string(transformation), transformation.format], present).join("/")
  ).join("|")

build_custom_headers = (headers) ->
  if !headers?
    return undefined
  else if _.isArray(headers)
    ;
  else if _.isObject(headers)
    headers = [k + ": " + v for k, v of headers]
  else
    return headers
  return headers.join("\n")

build_upload_params = (options) ->
  options ?= {}
  params =
    timestamp: timestamp(),
    transformation: generate_transformation_string(options),
    public_id: options.public_id,
    callback: options.callback,
    format: options.format,
    backup: options.backup,
    faces: options.faces,
    exif: options.exif,
    image_metadata: options.image_metadata,
    colors: options.colors,
    type: options.type,
    eager: build_eager(options.eager),
    headers: build_custom_headers(options.headers),
    use_filename: options.use_filename,
    notification_url: options.notification_url,
    eager_notification_url: options.eager_notification_url,
    eager_async: options.eager_async,
    invalidate: options.invalidate,
    tags: options.tags && build_array(options.tags).join(",")
  params

timestamp = ->
  Math.floor(new Date().getTime()/1000)

option_consume = (options, option_name, default_value) ->
  result = options[option_name]
  delete options[option_name]

  if result? then result else default_value

build_array = (arg) ->
  if !arg?
    []
  else if _.isArray(arg)
    arg
  else
    [arg]

exports.present = present = (value) ->
  not _.isUndefined(value) and ("" + value).length > 0


generate_transformation_string = (options) ->
  if _.isArray(options)
    result = for base_transformation in options
      generate_transformation_string(_.clone(base_transformation))
    return result.join("/")

  width = options["width"]
  height = options["height"]
  size = option_consume(options, "size")
  [options["width"], options["height"]] = [width, height] = size.split("x") if size

  has_layer = options.overlay or options.underlay
  crop = option_consume(options, "crop")
  angle = build_array(option_consume(options, "angle")).join(".")
  no_html_sizes = has_layer or present(angle) or crop == "fit" or crop == "limit"

  delete options["width"] if width and (no_html_sizes or parseFloat(width) < 1)
  delete options["height"] if height and (no_html_sizes or parseFloat(height) < 1)
  background = option_consume(options, "background")
  background = background and background.replace(/^#/, "rgb:")
  base_transformations = build_array(option_consume(options, "transformation", []))
  named_transformation = []
  if _.filter(base_transformations, _.isObject).length > 0
    base_transformations = _.map(base_transformations, (base_transformation) ->
      if _.isObject(base_transformation)
        generate_transformation_string(_.clone(base_transformation))
      else
        generate_transformation_string(transformation: base_transformation)
    )
  else
    named_transformation = base_transformations.join(".")
    base_transformations = []
  effect = option_consume(options, "effect")
  effect = effect.join(":") if _.isArray(effect)

  border = option_consume(options, "border")
  if _.isObject(border)
    border = "#{border.width ? 2}px_solid_#{(border.color ? "black").replace(/^#/, 'rgb:')}"
  flags = build_array(option_consume(options, "flags")).join(".")

  params =
    c: crop
    t: named_transformation
    w: width
    h: height
    b: background
    e: effect
    a: angle
    bo: border
    fl: flags

  simple_params =
    x: "x"
    y: "y"
    radius: "r"
    gravity: "g"
    quality: "q"
    prefix: "p"
    default_image: "d"
    underlay: "u"
    overlay: "l"
    fetch_format: "f"
    density: "dn"
    page: "pg"
    color_space: "cs"
    delay: "dl"
    opacity: "o"

  for param, short of simple_params
    params[short] = option_consume(options, param)

  params = _.sortBy([key, value] for key, value of params, (key, value) -> key)

  params.push [option_consume(options, "raw_transformation")]
  transformation = (param.join("_") for param in params when present(_.last(param))).join(",")

  base_transformations.push transformation
  _.filter(base_transformations, present).join "/"


