module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        options:
          bare: true
        files:
          'dist/ama.js': ['coffee/lib/**/*.coffee'],
          'test/test_suite': ['coffee/test/**/*.coffee']

    mocha:
      options:
        run: true
      all:
        src: 'test/testrunner.html'

  grunt.loadNpmtasks 'grunt-contrib-coffee'
  grunt.loadNpmtasks 'grunt-mocha'

  grunt.registerTask 'test', ['coffee', 'mocha']
