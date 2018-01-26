/* eslint-disable */

"use strict";

const fs = require('fs');
const gulp = require('gulp');
const exec = require('child_process').exec;
const clean = require('gulp-clean')
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


gulp.task('install', ['closeApp', 'cleanup', 'build','build', 'package', 'deploy'], function () {})
gulp.task('test', ['closeApp', 'cleanup', 'build','build_test', 'package_test', 'deploy_test'], function () {})

gulp.task('deploy', ['closeApp', 'cleanup', 'build', 'package'], function () {
  var roku_ip = (env_roku_ip == undefined) ? buildConfig.default_roku_target : env_roku_ip
  var roku_user = (env_roku_user == undefined) ? buildConfig.default_roku_user : env_roku_user
  var roku_pass = (env_roku_pass == undefined) ? buildConfig.default_roku_pass : env_roku_pass
  console.debug("Deploying to device IP: " + roku_ip + " (" + roku_user + " | " + roku_pass + ")")

  var curlCommand = "curl --user " + roku_user + ":" + roku_pass 
                    + " --digest --show-error -F 'mysubmit=Install' -F 'archive=@" + buildConfig.out_dir_name + "/" + buildConfig.app_name 
                    + ".zip' --output /tmp/dev_server_out --write-out '%{http_code}' http://" + roku_ip + "/plugin_install"
  console.log("curlCommand:"+curlCommand)
  var response = exec(curlCommand)
})

gulp.task('deploy_test', ['closeApp', 'cleanup', 'build', 'package'], function () {
  var roku_ip = (env_roku_ip == undefined) ? buildConfig.default_roku_target : env_roku_ip
  var roku_user = (env_roku_user == undefined) ? buildConfig.default_roku_user : env_roku_user
  var roku_pass = (env_roku_pass == undefined) ? buildConfig.default_roku_pass : env_roku_pass
  console.debug("Deploying to device IP: " + roku_ip + " (" + roku_user + " | " + roku_pass + ")")

  var curlCommand = "curl --user " + roku_user + ":" + roku_pass 
                    + " --digest --show-error -F 'mysubmit=Install' -F 'archive=@" + buildConfig.out_dir_name + "/" + buildConfig.app_name + "-tests" 
                    + ".zip' --output /tmp/dev_server_out --write-out '%{http_code}' http://" + roku_ip + "/plugin_install"
  // console.log("curlCommand:"+curlCommand)
  var response = exec(curlCommand)
})

gulp.task('build',['cleanup'], function () {
  return gulp.src(['source/**', 'components/**','images/**', 'manifest'], { "base" : "." }).pipe(gulp.dest(buildConfig.build_dir_name));
})

gulp.task('build_test',['build', 'cleanup'], function () {
  return gulp.src(['test/tests/**', 'test/test-framework/**', 'test/test-framework/manifest*']).pipe(gulp.dest(buildConfig.build_dir_name))
})

gulp.task('package_test', ['build', 'build_test', 'cleanup'], function () {
  return gulp.src('build/**')
    .pipe(zip(buildConfig.app_name + "-tests" + ".zip"))
    .pipe(gulp.dest('out/'));
})

gulp.task('package', ['build', 'cleanup'], function () {
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

gulp.task('cleanup', function () {
  return gulp.src('build')
    .pipe(clean());
})

