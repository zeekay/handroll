require 'shortcake'

use 'cake-test'
use 'cake-publish'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ['bootstrap'], ->
  handroll = require './dist/bootstrap.js'

  bundle = yield handroll.bundle
    entry:     'src/index.coffee'
    external:  true
    sourceMap: true

  yield bundle.write format: 'cjs'
  yield bundle.write format: 'es'

  bundle = yield handroll.bundle
    entry:     'src/cli.coffee'
    external:   true
    sourceMap:  false
    executable: true

  yield bundle.write
    dest:   'bin/handroll'
    format: 'bin'

task 'bootstrap', 'Build bootstrapped version of handroll', ->
  coffee      = require 'rollup-plugin-coffee-script'
  nodeResolve = require 'rollup-plugin-node-resolve'
  rollup      = require 'rollup'

  pkg = require './package.json'

  plugins = [
    coffee()
    nodeResolve
      extensions: ['.js', '.coffee']
      module:     true
  ]

  # CommonJS bootstrap lib
  bundle = yield rollup.rollup
    acorn:
      allowReserved: true

    entry:     'src/index.coffee'
    external:  Object.keys pkg.dependencies
    plugins:   plugins
    sourceMap: true

  bundle.write
    dest:      './dist/bootstrap.js'
    format:    'cjs'
    sourceMap: true


task 'watch', 'watch project and build on changes', ->
  build = (filename) ->
    console.log filename, 'modified, rebuilding'
    invoke 'build' if not running 'build'
  watch 'src/*.coffee',  build
  watch 'node_modules/', build, watchSymlink: true

task 'test', 'test handroll', ['build']
