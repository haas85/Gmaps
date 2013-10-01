module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    meta:
      file        : 'Gmaps'
      endpoint    : 'package/'


      banner            : """
        /* <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("m/d/yyyy") %>
           <%= pkg.homepage %>
           Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %> - Licensed <%= _.pluck(pkg.license, "type").join(", ") %> */

        """
    source: [
      "src/map.coffee"
      ,"src/route.coffee"
      ,"src/geometry.coffee"
    ]

    coffee: "<%= meta.endpoint %><%= meta.file %>.debug.js": ["<%= source %>"]

    uglify:
      options         : compress: false, banner: "<%= meta.banner %>"
      app             : files: "<%= meta.endpoint %><%= meta.file %>.js": "<%= meta.endpoint %><%= meta.file %>.debug.js"

    watch:
      lib:
        files: ["<%= source %>"]
        tasks: ["coffee","uglify"]


  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"


  grunt.registerTask "default", ["coffee", "uglify"]

