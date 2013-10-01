class Route
  constructor: (origin, destination, @properties={}, waypoints=[], callback) ->
    @id = _guid()

    @directionsDisplay = new google.maps.DirectionsRenderer()
    @directionsService = new google.maps.DirectionsService()

    @path = (location: point for point in waypoints).concat []
    @origin = location: origin
    @destination = location: destination

    @properties.optimizeWaypoints = true unless @properties.optimizeWaypoints?
    @properties.travelMode = _getTransport("CAR") unless @properties.travelMode?

    @calculate callback if callback?

  calculate: (callback) ->
    @properties.origin = @origin.location
    @properties.destination = @destination.location
    @properties.waypoints = @path

    @directionsService.route @properties, (@directions, status) =>
      if status is google.maps.DirectionsStatus.OK
        @directionsDisplay.setDirections @directions if @directionsDisplay.getMap()?
        callback.call callback, null, @directions if callback?
      else
        callback.call callback status, null if callback?

  addPoint: (point, callback) ->
    if point.latitude? and point.longitude?
      point = new google.maps.LatLng point.latitude, point.longitude

    @path.push @destination
    @destination = location: point

    @calculate callback

  setMap: (map) ->
    @directionsDisplay.setMap map
    @directionsDisplay.setDirections @directions if @directions? and map?

  getStaticPath: (index=0, options={})->
    step = @directions.routes[0].legs[0].steps[index]
    path = ""
    distance = parseInt(step.path.length / 15, 10)
    i = 0
    while i  < step.path.length
      path += "|#{step.path[i].lb},#{step.path[i].mb}"
      i += distance
    center = parseInt(step.path.length / 2, 10)
    path_properties = ""
    if options.color?
      path_properties += "color:#{options.color}"
      `delete options.color`
    else
      path_properties += "color:black"

    if options.weight?
      path_properties += ",weight:#{options.weight}"
      `delete options.weight`
    else
      path_properties += ",weight:5"
    options.client = 5 if Gmaps.client?
    options.signature = 5 if Gmaps.signature?
    options.size = "1000x1000" unless options.size?

    properties = ("#{key}=#{options[key]}" for key of options).join "&"
    url = "http://maps.googleapis.com/maps/api/staticmap?center=#{step.path[center].lb},#{step.path[center].mb}&path=#{path_properties}#{path}&zoom=15&#{properties}&sensor=false"

  _getTransport = (type) ->
    TRANSPORT_TYPES =
      BIKE     : google.maps.DirectionsTravelMode.BICYCLING
      CAR      : google.maps.DirectionsTravelMode.DRIVING
      TRANSIT  : google.maps.DirectionsTravelMode.TRANSIT
      WALK     : google.maps.DirectionsTravelMode.WALKING
    TRANSPORT_TYPES[type]

  _guid = ->
    "xxxxxxxx-xxxx-#{new Date().getTime()}-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else r & 3 | 8
      v.toString 16
    .toUpperCase()


window.Gmaps.Route = Route