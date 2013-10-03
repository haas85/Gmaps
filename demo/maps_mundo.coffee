initialize = ->
  window.map = new Gmaps.Map("map", disableDefaultUI: true)

  document.getElementById("onSearch").addEventListener "click", onSearch

  document.getElementById("onRoute").addEventListener "click", calculateRoute

  document.getElementById("onMarkerRoute").addEventListener "click", calculateMarkerRoute

  document.getElementById("onZoomIn").addEventListener "click", =>
    do window.map.zoomIn

  document.getElementById("onZoomOut").addEventListener "click", =>
    do window.map.zoomOut

  document.getElementById("onHybrid").addEventListener "click", =>
    window.map.type "HYBRID"

  document.getElementById("onRoad").addEventListener "click", =>
    window.map.type "ROAD"

  document.getElementById("onSatellite").addEventListener "click", =>
    window.map.type "SATELLITE"

  document.getElementById("onTerrain").addEventListener "click", =>
    window.map.type "TERRAIN"

getTransport = ->
  TRANSPORT_TYPES =
    BIKE     : google.maps.DirectionsTravelMode.BICYCLING
    CAR      : google.maps.DirectionsTravelMode.DRIVING
    TRANSIT  : google.maps.DirectionsTravelMode.TRANSIT
    WALK     : google.maps.DirectionsTravelMode.WALKING
  TRANSPORT_TYPES[document.querySelector('input[name="transport"]:checked').value]


google.maps.event.addDomListener window, "load", initialize



markerOnClick = ->
  window.map.off "click"
  window.map.on "click", (event) -> window.map.addMarker event.latLng

polylineOnClick = ->
  window.map.off "click"
  window.map.on "click", (event) ->
    window.polyline = window.polyline or new Gmaps.Polyline()
    window.map.addPolyline window.polyline
    window.polyline.addPoint event.latLng

polygonOnClick = ->
  window.map.off "click"
  window.map.on "click", (event) ->
    window.polygon = window.polygon or new Gmaps.Polygon()
    window.map.addPolygon window.polygon
    window.polygon.addPoint event.latLng

geodesicOnClick = ->
  window.map.off "click"
  window.map.on "click", (event) ->
    window.geodesic = window.geodesic or new Gmaps.Geodesic()
    window.map.addGeodesic window.geodesic
    window.geodesic.addPoint event.latLng


search = new google.maps.places.Autocomplete document.getElementById("place_search")
# @search.bindTo 'bounds', @map

from = new google.maps.places.Autocomplete document.getElementById("from")
# @from.bindTo 'bounds', @map

to = new google.maps.places.Autocomplete document.getElementById("to")
# @to.bindTo 'bounds', @map


onSearch = ->
  place = search.getPlace()
  return alert("Sitio no encontrado") unless place?
  window.map.addMarker place.geometry.location, null, true

calculateRoute = ->
  origin = from.getPlace()
  destination = to.getPlace()
  return alert("Especifica destino y fin") unless origin? and destination?
  origin = from.getPlace().geometry.location
  destination = to.getPlace().geometry.location

  window.router = window.router or new Gmaps.Route(origin, destination, travelMode: getTransport(),[])
  window.map.addRoute window.router
  # window.router.calculate()
  window.router.calculate (error, result) ->
    console.log result
    if result?
      indications = document.getElementById("indications")
      indications.innerHtml = ""
      legs = result.routes[0].legs
      for l in [0...legs.length]
        for i in [0...legs[l].steps.length]
          el = document.createElement "li"
          el.innerHTML = legs[l].steps[i].instructions
          img = document.createElement "img"
          img.setAttribute "src", window.router.getStaticPath l, i, {size: "100x100"}
          el.appendChild img
          indications.appendChild el

    # https://developers.google.com/maps/documentation/javascript/directions?hl=es#DirectionsRequests
    # {
    #   origin: LatLng | String,
    #   destination: LatLng | String,
    #   travelMode: TravelMode,
    #   transitOptions: TransitOptions,
    #   unitSystem: UnitSystem,
    #   waypoints[]: DirectionsWaypoint,
    #   optimizeWaypoints: Boolean,
    #   provideRouteAlternatives: Boolean,
    #   avoidHighways: Boolean,
    #   avoidTolls: Boolean
    #   region: String
    # }


calculateMarkerRoute = ->
  waypoints = []
  for marker in window.map.getMarker()
    waypoints.push marker.position
    marker.setMap null
  origin = waypoints.shift()
  destination = waypoints.pop()

  window.router = window.router or new Gmaps.Route(origin, destination, travelMode: getTransport(), waypoints)
  window.map.addRoute window.router
  window.router.calculate (error, result) ->
    console.log result
    if result?
      indications = document.getElementById("indications")
      indications.innerHtml = ""
      legs = result.routes[0].legs
      for l in [0...legs.length]
        el = document.createElement "li"
        el.innerHTML = "You are at #{legs[l].start_address}"
        indications.appendChild el
        for i in [0...legs[l].steps.length]
          el = document.createElement "li"
          el.innerHTML = legs[l].steps[i].instructions
          img = document.createElement "img"
          img.setAttribute "src", window.router.getStaticPath l, i, {size: "100x100"}
          el.appendChild img
          indications.appendChild el
        el = document.createElement "li"
      el.innerHTML = "You are at #{legs[l].end_address}"
      indications.appendChild el





