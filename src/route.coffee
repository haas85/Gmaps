class Route
  constructor: (@properties={}, path=[], callback) ->
    @id = new Date().getTime()
    @path = (location: elem for elem in path)
    @origin = if @path.length > 0 then @path.shift() else null

    @properties.optimizeWaypoints = true unless @properties.optimizeWaypoints?
    @properties.travelMode = _getTransport("CAR") unless @properties.travelMode?

    @directionsService = new google.maps.DirectionsService()

    @calculate callback if callback?

  calculate: (callback) ->
    @destination = if @path.length > 0 then @path.pop() else null
    @properties.origin = @origin.location
    @properties.destination = @destination.location
    @properties.waypoints = @path

    @directionsService.route @properties, (response, status) ->
      if status is google.maps.GeocoderStatus.OK
        callback.call callback, null, response
      else
        callback.call callback status, null

  addPoint: (point, callback) ->
    if point.latitude? and point.longitude?
      point = new google.maps.LatLng point.latitude, point.longitude

    @path.push @destination
    @path.push location: point

    @calculate callback

  _getTransport = (type) ->
    TRANSPORT_TYPES =
      BIKE     : google.maps.DirectionsTravelMode.BICYCLING
      CAR      : google.maps.DirectionsTravelMode.DRIVING
      TRANSIT  : google.maps.DirectionsTravelMode.TRANSIT
      WALK     : google.maps.DirectionsTravelMode.WALKING
    TRANSPORT_TYPES[type]


window.Route = Route