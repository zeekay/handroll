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

  yield bundle.write formats: ['cjs', 'es']

  yield handroll.write
    entry:      'src/cli.coffee'
    executable: true
    external:   true
    format:     'cli'
    sourceMap:  false

task 'bootstrap', 'Build bootstrapped version of handroll', ->
  rollup      = require 'rollup'
  coffee2     = require 'rollup-plugin-coffee2'
  nodeResolve = require 'rollup-plugin-node-resolve'

  pkg = require './package.json'

  plugins = [
    coffee2()
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
  watch 'src/',          build
  watch 'node_modules/', build, watchSymlink: true

task 'test', 'test handroll', ['build']
