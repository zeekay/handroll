require 'shortcake'

use 'cake-outdated'
use 'cake-publish'
use 'cake-test'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf lib && rm -rf bin/handroll'

task 'bootstrap', 'Build bootstrapped version of handroll', ->
  rollup      = require 'rollup'
  coffee2     = require 'rollup-plugin-coffee2'
  nodeResolve = require 'rollup-plugin-node-resolve-magic'

  pkg      = require './package.json'
  external = (Object.keys pkg.dependencies).concat Object.keys pkg.devDependencies
  plugins  = [
    coffee2()
    nodeResolve()
  ]

  # CommonJS bootstrap lib
  bundle = yield rollup.rollup
    entry:     'src/index.coffee'
    acorn:     allowReserved: true
    external:  external
    plugins:   plugins
    sourceMap: true

  yield bundle.write
    dest:      'lib/bootstrap.js'
    format:    'cjs'
    sourceMap: true

task 'build', 'build project', ->
  handroll = require './lib/bootstrap.js'

  b = new handroll.Bundle
    external: true
    compilers:
      coffee:
        version: 1

  yield b.write
    entry:    'src/index.coffee'
    formats:  ['cjs', 'es']

  yield b.write
    entry:      'src/cli.coffee'
    format:     'cli'
    executable: true
    sourceMap:  false

task 'watch', 'watch project and build on changes', ->
  build = (filename) ->
    console.log filename, 'modified, rebuilding'
    invoke 'build' if not running 'build'
  watch 'src/',          build
  watch 'node_modules/', build, watchSymlink: true

task 'test', 'test handroll', ['build']
