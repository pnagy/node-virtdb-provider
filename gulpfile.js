var gulp = require('gulp');
var coffee = require('gulp-coffee');
var spawn = require('child_process').spawn;
var sourcemaps = require('gulp-sourcemaps');
var node;

var mocha = require('gulp-mocha');
require('coffee-script/register')
var istanbul = require('gulp-coffee-istanbul');

var jsFiles = [];
var coffeeFiles = ['*.coffee'];
var specFiles = ['test/*.coffee'];

gulp.task('coverage', function() {
  gulp.src(jsFiles.concat(coffeeFiles))
      .pipe(istanbul({
                includeUntested: true
            }))
      .pipe(istanbul.hookRequire())
      .on('finish', function() {
          gulp.src(specFiles)
            .pipe(mocha({
              reporter: 'spec'
            }))
            .pipe(istanbul.writeReports({
                dir: '.',
                reporters: ['cobertura']
            }));
        });
});


/**
 * $ gulp server
 * description: launch the server. If there's a server already running, kill it.
 */
gulp.task('coffee', function() {
    gulp.src('*.coffee')
        .pipe(sourcemaps.init())
        .pipe(coffee({bare: true}))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./lib'))
});

gulp.task('watch', ['coffee'], function()
{
    gulp.watch(['./*.coffee'], ['coffee']);
});

gulp.task('default', ['watch']);
