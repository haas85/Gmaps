(function() {
  var Map;

  window.Gmaps = {
    MAPS_KEY: null,
    CLIENT: null,
    SIGNATURE: null
  };

  Map = (function() {
    var _addElement, _getElement, _getMapType, _guid;

    function Map(container_id, options) {
      if (options == null) {
        options = {};
      }
      if (typeof google === "undefined" || google === null) {
        throw "Import google maps library";
      }
      this.id = new Date().getTime();
      if (options.zoom == null) {
        options.zoom = 6;
      }
      if (options.disableDefaultUI == null) {
        options.disableDefaultUI = false;
      }
      if (options.mapTypeId == null) {
        options.mapTypeId = _getMapType("ROAD");
      }
      if (options.center == null) {
        options.center = new google.maps.LatLng(40.41, -3.69);
      }
      this.map = new google.maps.Map(document.getElementById(container_id), options);
      this.elements = {
        markers: {},
        route: {},
        polyline: {},
        polygone: {},
        geodesic: {}
      };
    }

    Map.prototype.center = function(latitude, longitude) {
      var latLng;
      if ((latitude != null) && (longitude != null)) {
        latLng = new google.maps.LatLng(latitude, longitude);
        return this.map.setCenter(latLng);
      } else {
        return this.map.getCenter();
      }
    };

    Map.prototype.type = function(type) {
      var view;
      if (type != null) {
        view = _getMapType(type.toUpperCase());
        if (view != null) {
          return this.map.setMapTypeId(view);
        } else {
          throw "Invalid map type";
        }
      } else {
        return this.map.getMapTypeId();
      }
    };

    Map.prototype.zoom = function(level) {
      if (level != null) {
        return this.map.setZoom(level);
      } else {
        return this.map.getZoom();
      }
    };

    Map.prototype.zoomIn = function() {
      return this.map.setZoom(this.map.zoom + 1);
    };

    Map.prototype.zoomOut = function() {
      return this.map.setZoom(this.map.zoom - 1);
    };

    Map.prototype.on = function(type, callback) {
      return google.maps.event.addListener(this.map, type, callback);
    };

    Map.prototype.off = function(type) {
      return google.maps.event.clearInstanceListeners(this.map, type);
    };

    Map.prototype.search = function(text, callback) {
      if (this.geocoder == null) {
        this.geocoder = new google.maps.Geocoder();
      }
      return this.geocoder.geocode({
        address: text
      }, function(result, status) {
        if (status === google.maps.GeocoderStatus.OK) {
          return callback.call(callback, null, result[0]);
        } else {
          return callback.call(callback(status, null));
        }
      });
    };

    Map.prototype.addMarker = function(point, options, center) {
      var id;
      if (options == null) {
        options = {};
      }
      if ((point.latitude != null) && (point.longitude != null)) {
        point = new google.maps.LatLng(point.latitude, point.longitude);
      }
      id = _guid();
      options.map = this.map;
      options.position = point;
      this.elements.markers[id] = new google.maps.Marker(options);
      if (center) {
        this.map.setCenter(options.position);
      }
      return id;
    };

    Map.prototype.getMarker = function(id) {
      var key, _results;
      if (id != null) {
        return this.elements.markers[id];
      } else {
        _results = [];
        for (key in this.elements.markers) {
          _results.push(this.elements.markers[key]);
        }
        return _results;
      }
    };

    Map.prototype.deleteMarker = function(id) {
      if (this.elements.markers[id] != null) {
        this.elements.markers[id].setMap(null);
        return delete this.elements.markers[id];
      }
    };

    Map.prototype.addRoute = function(route) {
      return _addElement("route", route, this);
    };

    Map.prototype.addPolyline = function(polyline) {
      return _addElement("polyline", polyline, this);
    };

    Map.prototype.addPolygon = function(polygon) {
      return _addElement("polygon", polygon, this);
    };

    Map.prototype.addGeodesic = function(geodesic) {
      return _addElement("geodesic", geodesic, this);
    };

    _addElement = function(type, element, context) {
      element.setMap(context.map);
      return context.elements[type] = element;
    };

    Map.prototype.getRoute = function(id) {
      return _getElement("route", id, this);
    };

    Map.prototype.getPolyline = function(id) {
      return _getElement("polyline", id, this);
    };

    Map.prototype.getPolygon = function(id) {
      return _getElement("polygon", id, this);
    };

    Map.prototype.getGeodesic = function(id) {
      return _getElement("geodesic", id, this);
    };

    _getElement = function(type, id, context) {
      var key, _results;
      if (id != null) {
        return context.elements[type][id];
      } else {
        _results = [];
        for (key in context.elements[type]) {
          _results.push(context.elements[type][key]);
        }
        return _results;
      }
    };

    _getMapType = function(type) {
      var MAP_TYPES;
      MAP_TYPES = {
        HYBRID: google.maps.MapTypeId.HYBRID,
        ROAD: google.maps.MapTypeId.ROADMAP,
        SATELLITE: google.maps.MapTypeId.SATELLITE,
        TERRAIN: google.maps.MapTypeId.TERRAIN
      };
      return MAP_TYPES[type];
    };

    _guid = function() {
      return ("xxxxxxxx-xxxx-" + (new Date().getTime()) + "-xxxxxxxxxxxx").replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = c === 'x' ? r : r & 3 | 8;
        return v.toString(16);
      }).toUpperCase();
    };

    return Map;

  })();

  window.Gmaps.Map = Map;

}).call(this);

(function() {
  var Route;

  Route = (function() {
    var _getTransport, _guid;

    function Route(origin, destination, properties, waypoints, callback) {
      var point;
      this.properties = properties != null ? properties : {};
      if (waypoints == null) {
        waypoints = [];
      }
      this.id = _guid();
      this.directionsDisplay = new google.maps.DirectionsRenderer();
      this.directionsService = new google.maps.DirectionsService();
      this.path = ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = waypoints.length; _i < _len; _i++) {
          point = waypoints[_i];
          _results.push({
            location: point
          });
        }
        return _results;
      })()).concat([]);
      this.origin = {
        location: origin
      };
      this.destination = {
        location: destination
      };
      if (this.properties.optimizeWaypoints == null) {
        this.properties.optimizeWaypoints = true;
      }
      if (this.properties.travelMode == null) {
        this.properties.travelMode = _getTransport("CAR");
      }
      if (callback != null) {
        this.calculate(callback);
      }
    }

    Route.prototype.calculate = function(callback) {
      var _this = this;
      this.properties.origin = this.origin.location;
      this.properties.destination = this.destination.location;
      this.properties.waypoints = this.path;
      return this.directionsService.route(this.properties, function(directions, status) {
        _this.directions = directions;
        if (status === google.maps.DirectionsStatus.OK) {
          if (_this.directionsDisplay.getMap() != null) {
            _this.directionsDisplay.setDirections(_this.directions);
          }
          if (callback != null) {
            return callback.call(callback, null, _this.directions);
          }
        } else {
          if (callback != null) {
            return callback.call(callback(status, null));
          }
        }
      });
    };

    Route.prototype.addPoint = function(point, callback) {
      if ((point.latitude != null) && (point.longitude != null)) {
        point = new google.maps.LatLng(point.latitude, point.longitude);
      }
      this.path.push(this.destination);
      this.destination = {
        location: point
      };
      return this.calculate(callback);
    };

    Route.prototype.setMap = function(map) {
      this.directionsDisplay.setMap(map);
      if ((this.directions != null) && (map != null)) {
        return this.directionsDisplay.setDirections(this.directions);
      }
    };

    Route.prototype.getStaticPath = function(leg, index, options) {
      var center, distance, i, key, path, path_properties, properties, step;
      if (leg == null) {
        leg = 0;
      }
      if (index == null) {
        index = 0;
      }
      if (options == null) {
        options = {};
      }
      step = this.directions.routes[0].legs[leg].steps[index];
      path = "";
      distance = step.path.length < 15 ? 1 : parseInt(step.path.length / 15, 10);
      i = 0;
      while (i < step.path.length) {
        path += "|" + step.path[i].lb + "," + step.path[i].mb;
        i += distance;
      }
      center = parseInt(step.path.length / 2, 10);
      path_properties = "";
      if (options.color != null) {
        path_properties += "color:" + options.color;
        delete options.color;
      } else {
        path_properties += "color:black";
      }
      if (options.weight != null) {
        path_properties += ",weight:" + options.weight;
        delete options.weight;
      } else {
        path_properties += ",weight:5";
      }
      if (Gmaps.CLIENT != null) {
        options.client = Gmaps.CLIENT;
      }
      if (Gmaps.SIGNATURE != null) {
        options.signature = Gmaps.SIGNATURE;
      }
      if (options.size == null) {
        options.size = "1000x1000";
      }
      if (options.zoom == null) {
        options.zoom = "15";
      }
      properties = ((function() {
        var _results;
        _results = [];
        for (key in options) {
          _results.push("" + key + "=" + options[key]);
        }
        return _results;
      })()).join("&");
      return "http://maps.googleapis.com/maps/api/staticmap?center=" + step.path[center].lb + "," + step.path[center].mb + "&path=" + path_properties + path + "&" + properties + "&sensor=false";
    };

    _getTransport = function(type) {
      var TRANSPORT_TYPES;
      TRANSPORT_TYPES = {
        BIKE: google.maps.DirectionsTravelMode.BICYCLING,
        CAR: google.maps.DirectionsTravelMode.DRIVING,
        TRANSIT: google.maps.DirectionsTravelMode.TRANSIT,
        WALK: google.maps.DirectionsTravelMode.WALKING
      };
      return TRANSPORT_TYPES[type];
    };

    _guid = function() {
      return ("xxxxxxxx-xxxx-" + (new Date().getTime()) + "-xxxxxxxxxxxx").replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = c === 'x' ? r : r & 3 | 8;
        return v.toString(16);
      }).toUpperCase();
    };

    return Route;

  })();

  window.Gmaps.Route = Route;

}).call(this);

(function() {
  var Geodesic, Geometry, Polygon, Polyline,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Geometry = (function() {
    var _guid;

    function Geometry(properties, path) {
      this.properties = properties != null ? properties : {};
      if (path == null) {
        path = [];
      }
      this.id = _guid();
      this.path = path.concat([]);
      if (this.properties.strokeColor == null) {
        this.properties.strokeColor = '#FF0000';
      }
      if (this.properties.strokeOpacity == null) {
        this.properties.strokeOpacity = 1.0;
      }
      if (this.properties.strokeWeight == null) {
        this.properties.strokeWeight = 1;
      }
    }

    Geometry.prototype.load = function() {
      var current;
      current = new this.type(this.properties);
      if (this.element != null) {
        current.setMap(this.element.getMap());
        this.element.setMap(null);
      }
      return this.element = current;
    };

    Geometry.prototype.addPoint = function(point) {
      if ((point.latitude != null) && (point.longitude != null)) {
        point = new google.maps.LatLng(point.latitude, point.longitude);
      }
      this.path.push(point);
      return this.load();
    };

    Geometry.prototype.setMap = function(map) {
      return this.element.setMap(map);
    };

    _guid = function() {
      return ("xxxxxxxx-xxxx-" + (new Date().getTime()) + "-xxxxxxxxxxxx").replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = c === 'x' ? r : r & 3 | 8;
        return v.toString(16);
      }).toUpperCase();
    };

    return Geometry;

  })();

  Polyline = (function(_super) {
    __extends(Polyline, _super);

    function Polyline(properties, path) {
      this.properties = properties != null ? properties : {};
      if (path == null) {
        path = [];
      }
      Polyline.__super__.constructor.apply(this, arguments);
      this.type = google.maps.Polyline;
      this.properties.path = this.path;
      this.load();
    }

    return Polyline;

  })(Geometry);

  Polygon = (function(_super) {
    __extends(Polygon, _super);

    function Polygon(properties, path) {
      this.properties = properties != null ? properties : {};
      if (path == null) {
        path = [];
      }
      Polygon.__super__.constructor.apply(this, arguments);
      this.type = google.maps.Polygon;
      this.properties.paths = this.path;
      if (this.properties.fillColor == null) {
        this.properties.fillColor = '#FF0000';
      }
      if (this.properties.fillOpacity == null) {
        this.properties.fillOpacity = 0.35;
      }
      this.load();
    }

    return Polygon;

  })(Geometry);

  Geodesic = (function(_super) {
    __extends(Geodesic, _super);

    function Geodesic(properties, path) {
      this.properties = properties != null ? properties : {};
      if (path == null) {
        path = [];
      }
      this.properties.geodesic = true;
      Geodesic.__super__.constructor.call(this, this.properties, path);
    }

    return Geodesic;

  })(Polyline);

  window.Gmaps.Polyline = Polyline;

  window.Gmaps.Polygon = Polygon;

  window.Gmaps.Geodesic = Geodesic;

}).call(this);
