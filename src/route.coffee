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


window.Route = Route