class Gmap
  constructor: (container_id, options={}) ->
    throw "Import google maps library" unless google?
    @id = new Date().getTime()
    options.zoom = 7 unless options.zoom?
    options.disableDefaultUI = false unless options.disableDefaultUI?
    options.mapTypeId = _getMapType "ROAD" unless options.mapTypeId?
    options.center = new google.maps.LatLng(41, 2) unless options.center?

    @map = new google.maps.Map(document.getElementById(container_id), options)

    @elements =
      markers   : {}
      route     : {}
      polyline  : {}
      polygone  : {}
      geodesic  : {}

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

  addMarker: (latitude, longitude, options={}, center) ->
    id = new Date().getTime()
    options.map = @map
    options.position = new google.maps.LatLng(latitude, longitude)
    @elements.markers[id] = new google.maps.Marker(options)
    @map.setCenter options.position if center
    id

  getMarker: (id) -> @elements.markers[id]

  deleteMarker: (id) ->
    if @elements.markers[id]?
      @elements.markers[id].setMap null
      `delete this.elements.markers[id]`


  addRoute: (route) -> _addElement "route", route, @
  addPolyline: (polyline) -> _addElement "polyline", polyline, @
  addPolygon: (polygon) -> _addElement "polygon", polygon, @
  addGeodesic: (geodesic) -> _addElement "geodesic", geodesic, @

  _addElement = (type, element, context) ->
    element.setMap context.map
    context.elements[type] = element

  getRoute: (id) -> _getElement "route", id, @
  getPolyline: (id) -> _getElement "polyline", id, @
  getPolygon: (id) -> _getElement "polygon", id, @
  getGeodesic: (id) -> _getElement "geodesic", id, @

  _getElement = (type, id, context) ->
    if id? then context.elements[type][id] else throw "Id is required"

  _getMapType = (type) ->
    MAP_TYPES =
      HYBRID      : google.maps.MapTypeId.HYBRID
      ROAD        : google.maps.MapTypeId.ROADMAP
      SATELLITE   : google.maps.MapTypeId.SATELLITE
      TERRAIN     : google.maps.MapTypeId.TERRAIN
    MAP_TYPES[type]




window.Gmaps = Gmap