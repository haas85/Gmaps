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
    latLng = new google.maps.LatLng(latitude, longitude)
    @map.setCenter latLng

  type: (type="ROAD") ->
    view = _getMapType type.toUpperCase()
    if view?
      @map.setMapTypeId view
    else
      throw "Invalid map type"

  zoomIn: -> @map.setZoom(@map.zoom + 1)

  zoomOut: -> @map.setZoom(@map.zoom - 1)

  addPolyline: (polyline, hide_previous) ->
    console.log @
    _addElement "polyline", polyline, hide_previous, @

  addPolygon: (polygon, hide_previous) -> _addElement "polygon", polygon, hide_previous, @

  addGeodesic: (geodesic, hide_previous) -> _addElement "geodesic", geodesic, hide_previous, @

  _addElement = (type, element, hide, context) ->
    if context.current[type]?
      context.current[type].setMap = null if hide
      context.history[type][context.current[type].id] = context.current[type]

    element.setMap context.map
    console.log element
    context.current[type] = element

  _getMapType = (type) ->
    MAP_TYPES =
      HYBRID      : google.maps.MapTypeId.HYBRID
      ROAD        : google.maps.MapTypeId.ROADMAP
      SATELLITE   : google.maps.MapTypeId.SATELLITE
      TERRAIN     : google.maps.MapTypeId.TERRAIN
    MAP_TYPES[type]

window.Gmaps = Gmap