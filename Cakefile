require 'shortcake'

use 'cake-test'
use 'cake-publish'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'bootstrap', 'bootstrap handroll', ->
  coffee      = require 'rollup-plugin-coffee-script'
  nodeResolve = require 'rollup-plugin-node-resolve'
  rollup      = require 'rollup'

  pkg = require './package.json'

  plugins = [
    coffee()
    nodeResolve
      extensions: ['.js', '.coffee']
      module:  true
  ]

  # CommonJS bootstrap lib
  bundle = yield rollup.rollup
    acorn:
      allowReserved: true
    entry:      'src/index.coffee'
    external:   Object.keys pkg.dependencies
    plugins:    plugins
    sourceMap:  true

  bundle.write
    dest:       './dist/bootstrap.js'
    format:     'cjs'
    sourceMap:  true

task 'build', 'build project', ['bootstrap'], ->
  handroll = require './dist/bootstrap.js'

  bundle = yield handroll.bundle
    entry:    'src/index.coffee'
    external: true
    sourceMap: true

  yield bundle.write format: 'cjs'
  yield bundle.write format: 'es'

task 'test', 'test handroll', ['build']
