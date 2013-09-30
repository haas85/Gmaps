class Geometry
  constructor: (@properties={}, path=[]) ->
    @id = _guid()
    @path = path.concat []
    @properties.strokeColor = '#FF0000' unless @properties.strokeColor?
    @properties.strokeOpacity = 1.0 unless @properties.strokeOpacity?
    @properties.strokeWeight = 1 unless @properties.strokeWeight?

  load: () ->
    current = new @type(@properties)
    if @element?
      current.setMap @element.getMap()
      @element.setMap null
    @element = current

  addPoint: (point) ->
    if point.latitude? and point.longitude?
      point = new google.maps.LatLng point.latitude, point.longitude

    @path.push point
    do @load

  setMap: (map) -> @element.setMap map

  _guid = ->
    "xxxxxxxx-xxxx-#{new Date().getTime()}-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else r & 3 | 8
      v.toString 16
    .toUpperCase()

class Polyline extends Geometry
  constructor: (@properties={}, path=[]) ->
    super
    @type = google.maps.Polyline
    @properties.path = @path

    do @load

class Polygon extends Geometry
  constructor: (@properties={}, path=[]) ->
    super
    @type = google.maps.Polygon
    @properties.paths = @path
    @properties.fillColor = '#FF0000' unless @properties.fillColor?
    @properties.fillOpacity = 0.35 unless @properties.fillOpacity?

    do @load

class Geodesic extends Polyline
  constructor: (@properties={}, path=[]) ->
    @properties.geodesic = true
    super @properties, path

window.Polyline = Polyline
window.Polygon = Polygon
window.Geodesic = Geodesic