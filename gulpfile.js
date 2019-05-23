/* eslint-disable */

"use strict";

const fs = require('fs');
const gulp = require('gulp');
const exec = require('child_process').exec;
const clean = require('gulp-clean')
const rename = require("gulp-rename");
const replace = require('gulp-replace');
const zip = require('gulp-zip');
const path = require('path');
const info = require('./package.json');
const buildConfig = require('./build_config.json');
const env_roku_ip = process.env.ROKU_DEV_TARGET
const env_roku_user = process.env.DEVUSER
const env_roku_pass = process.env.DEVPASSWORD


// const gitRev = require('git-rev-sync');
const now = new Date();
var lookupIpAddress;

info.date = now.getFullYear().toString() + ("0" + (now.getMonth() + 1)).slice(-2) + ("0" + (now.getDate().toString())).slice(-2);


gulp.task('install', ['closeApp', 'cleanup', 'build_sample_app', 'build_components', 'package', 'deploy'], function () {
    return gulp.src('build')
    .pipe(clean());
})
gulp.task('test', ['closeApp', 'cleanup', 'build_test_source', 'add_test_framework', 'add_mux_library_to_test','package_test', 'deploy_test'], function () {
  return gulp.src('build')
    .pipe(clean());
})

gulp.task('deploy', ['closeApp', 'cleanup', 'build_sample_app','build_components', 'package'], function () {
  var roku_ip = (env_roku_ip == undefined) ? buildConfig.default_roku_target : env_roku_ip
  var roku_user = (env_roku_user == undefined) ? buildConfig.default_roku_user : env_roku_user
  var roku_pass = (env_roku_pass == undefined) ? buildConfig.default_roku_pass : env_roku_pass
  console.log("Deploying to device IP: " + roku_ip + " (" + roku_user + " | " + roku_pass + ")")

  var curlCommand = "curl --user " + roku_user + ":" + roku_pass
                    + " --digest --show-error -F 'mysubmit=Install' -F 'archive=@" + buildConfig.out_dir_name + "/" + buildConfig.app_name
                    + ".zip' --output /tmp/dev_server_out --write-out '%{http_code}' http://" + roku_ip + "/plugin_install"
  console.log("curlCommand:"+curlCommand)
  var response = exec(curlCommand)
})

gulp.task('build_sample_app',['cleanup'], function () {
  return gulp.src(['sampleapp_source/source/**', 'sampleapp_source/components/**', 'sampleapp_source/libs/**','sampleapp_source/images/**', 'sampleapp_source/feed/**', 'sampleapp_source/manifest'], { "base" : "sampleapp_source" })
  .pipe(gulp.dest(buildConfig.build_dir_name));
})

gulp.task('build_components',['cleanup', 'build_sample_app'], function () {
  if (buildConfig.sample_app_type == "recycle_video")
  {
    return gulp.src(['sampleapp_source/components_recycled/**'], { "base" : "sampleapp_source/components_recycled" })
      .pipe(gulp.dest(buildConfig.build_dir_name));
  }
  else
  {
    return gulp.src(['sampleapp_source/components_reset/**'], { "base" : "sampleapp_source/components_reset" })
      .pipe(gulp.dest(buildConfig.build_dir_name));
  }
})

gulp.task('build_src',['cleanup', 'build_sample_app', 'build_components'], function () {
  return gulp.src(['src/**'], { "base" : "src" })
    .pipe(gulp.dest(buildConfig.build_dir_name + "/libs"));
})

gulp.task('deploy_test', ['closeApp', 'cleanup', 'build_sample_app', 'package_test'], function () {
  var roku_ip = (env_roku_ip == undefined) ? buildConfig.default_roku_target : env_roku_ip
  var roku_user = (env_roku_user == undefined) ? buildConfig.default_roku_user : env_roku_user
  var roku_pass = (env_roku_pass == undefined) ? buildConfig.default_roku_pass : env_roku_pass
  console.log("Deploying to device IP: " + roku_ip + " (" + roku_user + " | " + roku_pass + ")")

  var curlCommand = "curl --user " + roku_user + ":" + roku_pass
                    + " --digest --show-error -F 'mysubmit=Install' -F 'archive=@" + buildConfig.out_dir_name + "/" + buildConfig.app_name + "-tests"
                    + ".zip' --output /tmp/dev_server_out --write-out '%{http_code}' http://" + roku_ip + "/plugin_install"
  // console.log("curlCommand:"+curlCommand)
  var response = exec(curlCommand)
})

gulp.task('lint', function () {
  var bsLintVersion = "bslint --version"
  exec(bsLintVersion, {}, function(err, stdout, stderr) {
    err && console.log("missing linter see https://github.com/sky-uk/bslint")
    stdout && exec("bslint -l", {}, function(err, stdout, stderr) {
      console.log("******************************************************************************")
      console.log("If you are seeing an error of the type: \"No manifest file found\" that is ok")
      console.log("The reason behind this is due to the manifest being located within the sampleapp_source")
      console.log("as the scope of this project a bit different than a regular ROKU application")
      console.log("******************************************************************************")
      console.log(stdout)
    })
  })
})

gulp.task('build_test_source',['build_sample_app', 'cleanup'], function () {
  return gulp.src(['test/source_tests/**']).pipe(gulp.dest(buildConfig.build_dir_name))
})

gulp.task('build_test_components',['build_sample_app', 'cleanup'], function () {
  return gulp.src(['test/component_tests/**']).pipe(gulp.dest(buildConfig.build_dir_name))
})

gulp.task('add_test_framework',['cleanup', 'build_sample_app', 'build_test_source'], function () {
  return gulp.src(['test/testFramework/*'], { "base" : "test" }).pipe(gulp.dest(buildConfig.build_dir_name + "/source"))
})

gulp.task('add_mux_library_to_test',['cleanup', 'build_sample_app', 'build_test_source'], function () {
  return gulp.src(['src/mux-analytics.brs']).pipe(gulp.dest(buildConfig.build_dir_name + "/source"))
})

gulp.task('package_test', ['build_sample_app', 'build_test_source', 'add_test_framework','add_mux_library_to_test'], function () {
  return gulp.src('build/**')
    .pipe(zip(buildConfig.app_name + "-tests" + ".zip"))
    .pipe(gulp.dest('out/'));
})

gulp.task('package', ['build_sample_app', 'build_components', 'build_src', 'cleanup'], function () {
  return gulp.src('build/**')
    .pipe(zip(buildConfig.app_name + ".zip"))
    .pipe(gulp.dest('out/'));
})

gulp.task('closeApp', function () {
  console.log("Close App");
  var roku_ip = (env_roku_ip == undefined) ? buildConfig.default_roku_target : env_roku_ip
  var closeCommand = "curl -d '' http://" + roku_ip + ":8060/keypress/home"
  console.log(closeCommand)
  var response = exec(closeCommand)
})

gulp.task('replace', ['build_sample_app', 'cleanup'], function () {
  gulp.src(['build/libs/mux-analytics.brs'])
    .pipe(replace('player_software_name', 'pswnm'))
    .pipe(replace('player_software_version', 'pswve'))
    .pipe(replace('player_model_number', 'pmono'))
    .pipe(replace('player_mux_plugin_name', 'pmxpinm'))
    .pipe(replace('player_mux_plugin_version', 'pmxpive'))
    .pipe(replace('player_language_code', 'placd'))
    .pipe(replace('player_width', 'pwd'))
    .pipe(replace('player_height', 'pht'))
    .pipe(replace('player_error_code', 'percd'))
    .pipe(replace('player_error_message', 'perme'))
    .pipe(replace('player_is_fullscreen', 'pisfs'))
    .pipe(replace('player_is_paused', 'pispa'))
    .pipe(replace('video_source_url', 'vsour'))
    .pipe(replace('video_source_hostname', 'vsohn'))
    .pipe(replace('video_source_domain', 'vsodm'))
    .pipe(replace('video_source_format', 'vsoft'))
    .pipe(replace('video_source_duration', 'vsodu'))
    .pipe(replace('video_source_is_live', 'vsoisli'))
    .pipe(replace('video_source_width', 'vsowd'))
    .pipe(replace('video_source_height', 'vsoht'))
    .pipe(replace('video_title', 'vtt'))
    .pipe(replace('video_series', 'vsr'))
    .pipe(replace('video_producer', 'vpd'))
    .pipe(replace('video_content_type', 'vctty'))
    .pipe(replace('video_id', 'vid'))
    .pipe(replace('viewer_user_id', 'uusid'))
    .pipe(replace('view_time_to_first_frame', 'xtitofifr'))
    .pipe(gulp.dest('build/libs/'));
});

gulp.task('templates', function(){

});

gulp.task('cleanup', function () {
  return gulp.src('build')
    .pipe(clean());
})

function sleep(delay) {
  console.log("Start sleep")
  var start = new Date().getTime();
  while (new Date().getTime() < start + delay);
  console.log("end sleep")
}

const firstWordsByMin = {
  'a': 'property', // account
  'b': 'beacon',
  'd': 'ad',
  'e': 'event',
  'f': 'experiment', // nothing better to use...
  'm': 'mux',
  'p': 'player',
  'r': 'retry', // placeholder for beacons adding retry counts
  's': 'session',
  't': 'timestamp',
  'u': 'viewer', // user
  'v': 'video',
  'w': 'page', // web page
  'x': 'view',
  'y': 'sub' // cause nowhere else to fit it
};

const expectedWordsByMin = {
  'ad': 'ad',
  'ag': 'aggregate',
  'ap': 'api',
  'al': 'application',
  'ar': 'architecture',
  'as': 'asset',
  'au': 'autoplay',
  'br': 'break',
  'cd': 'code',
  'cg': 'category',
  'cn': 'config',
  'co': 'count',
  'cp': 'complete',
  'ct': 'content',
  'cu': 'current',
  'dg': 'downscaling',
  'dm': 'domain',
  'dn': 'cdn',
  'do': 'downscale',
  'du': 'duration',
  'dv': 'device',
  'ec': 'encoding',
  'en': 'end',
  'eg': 'engine',
  'em': 'embed',
  'er': 'error',
  'ev': 'events',
  'ex': 'expires',
  'fi': 'first',
  'fm': 'family',
  'ft': 'format',
  'fq': 'frequency',
  'fr': 'frame',
  'fs': 'fullscreen',
  'ho': 'host',
  'hn': 'hostname',
  'ht': 'height',
  'id': 'id',
  'ii': 'init',
  'in': 'instance',
  'ip': 'ip',
  'is': 'is',
  'ke': 'key',
  'la': 'language',
  'li': 'live',
  'lo': 'load',
  'ma': 'max',
  'me': 'message',
  'mi': 'mime',
  'ml': 'midroll',
  'mn': 'manufacturer',
  'mo': 'model',
  'mx': 'mux',
  'nm': 'name',
  'no': 'number',
  'on': 'on',
  'os': 'os',
  'pa': 'paused',
  'pb': 'playback',
  'pd': 'producer',
  'pe': 'percentage',
  'pf': 'played',
  'ph': 'playhead',
  'pi': 'plugin',
  'pl': 'preroll',
  'po': 'poster',
  'pr': 'preload',
  'py': 'property',
  'ra': 'rate',
  'rd': 'requested',
  're': 'rebuffer',
  'ro': 'ratio',
  'rq': 'request',
  'rs': 'requests',
  'sa': 'sample',
  'se': 'session',
  'sk': 'seek',
  'sm': 'stream',
  'so': 'source',
  'sq': 'sequence',
  'sr': 'series',
  'st': 'start',
  'su': 'startup',
  'sv': 'server',
  'sw': 'software',
  'ta': 'tag',
  'tc': 'tech',
  'ti': 'time',
  'tl': 'total',
  'to': 'to',
  'tt': 'title',
  'ty': 'type',
  'ug': 'upscaling',
  'up': 'upscale',
  'ur': 'url',
  'us': 'user',
  'va': 'variant',
  'vd': 'viewed',
  'vi': 'video',
  've': 'version',
  'vw': 'view',
  'vr': 'viewer',
  'wd': 'width',
  'wa': 'watch',
  'wt': 'waiting'
};

