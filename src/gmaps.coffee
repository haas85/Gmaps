class Gmap
  constructor: (container_id, options={}) ->
    throw "Import google maps library" unless google?
    options.zoom = 7 unless options.zoom?
    options.disableDefaultUI = false unless options.disableDefaultUI?
    options.mapTypeId = _getMapType "ROAD" unless options.mapTypeId?
    options.center = new google.maps.LatLng(41, 2) unless options.center?

    @map = new google.maps.Map(document.getElementById(container_id), options)

    @history =
      polyline: {}
      polygone: {}
      geodesic: {}

    @current =
      polyline: null
      polygone: null
      geodesic: null

  center: (latitude, longitude) ->
    if latitude? and longitude?
      latLng = new google.maps.LatLng(latitude, longitude)
      @map.setCenter latLng
    else
      @map.getCenter()

  type: (type) ->
    if type?
      view = _getMapType type.toUpperCase()
      if view?
        @map.setMapTypeId view
      else
        throw "Invalid map type"
    else
      @map.getMapTypeId()

  zoom: (level) -> if level? then @map.setZoom(level) else @map.getZoom()

  zoomIn: -> @map.setZoom(@map.zoom + 1)

  zoomOut: -> @map.setZoom(@map.zoom - 1)

  on: (type, callback) -> google.maps.event.addListener @map, type, callback

  off: (type) -> google.maps.event.clearInstanceListeners @map, type

  search: (text, callback) ->
    @geocoder = new google.maps.Geocoder() unless @geocoder?
    @geocoder.geocode {address: text}, (result, status) ->
      if status is google.maps.GeocoderStatus.OK
        callback.call callback, null, result[0]
      else
        callback.call callback status, null

  addPolyline: (polyline, hide_previous) ->
    _addElement "polyline", polyline, hide_previous, @

  addPolygon: (polygon, hide_previous) -> _addElement "polygon", polygon, hide_previous, @

  addGeodesic: (geodesic, hide_previous) -> _addElement "geodesic", geodesic, hide_previous, @

  _addElement = (type, element, hide, context) ->
    if context.current[type]?
      context.current[type].setMap = null if hide
      context.history[type][context.current[type].id] = context.current[type]

    element.setMap context.map
    context.current[type] = element

  _getMapType = (type) ->
    MAP_TYPES =
      HYBRID      : google.maps.MapTypeId.HYBRID
      ROAD        : google.maps.MapTypeId.ROADMAP
      SATELLITE   : google.maps.MapTypeId.SATELLITE
      TERRAIN     : google.maps.MapTypeId.TERRAIN
    MAP_TYPES[type]

window.Gmaps = Gmap