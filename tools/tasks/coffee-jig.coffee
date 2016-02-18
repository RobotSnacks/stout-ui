###

coffee:src Gulp Task

Transpiles all source CoffeeScript files.

###

coffee     = require 'gulp-coffee'
gulp       = require('gulp-help')(require 'gulp')
gutil      = require 'gulp-util'
sourcemaps = require 'gulp-sourcemaps'



module.exports = (config, options) ->

  src = config.path.jig + '/**/*.coffee'
  name = 'coffee:jig'

  gulp.task name, false, ['coffee:src'], ->
    if options.watch then gulp.watch src, [name]
    gulp.src src
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write config.path.jig,
      includeContent: true
      sourceRoot: '../' + config.path.src
    .pipe gulp.dest config.path.jig
    .on 'error', gutil.log
