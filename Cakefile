require 'shortcake'

use 'cake-outdated'
use 'cake-publish'
use 'cake-test'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ['bootstrap'], ->
  handroll = require './dist/bootstrap.js'

  pkg = require './package.json'

  bundle = yield handroll.bundle
    entry:    'src/index.coffee'
    external: true

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
  nodeResolve = require 'rollup-plugin-node-resolve-magic'

  pkg = require './package.json'

  external = (Object.keys pkg.dependencies).concat Object.keys pkg.devDependencies

  plugins = [
    coffee2()
    nodeResolve
      extensions: ['.js', '.coffee']
      external:   external
      jsnext:     true
      module:     true
  ]

  # CommonJS bootstrap lib
  bundle = yield rollup.rollup
    entry:     'src/index.coffee'
    acorn:     allowReserved: true
    external:  external
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

task 'bundle:legacy', '', ->
  handroll = require './dist/bootstrap.js'
  handroll.write
    entry:  'test.coffee'
    dest:   'test.js'
    format: 'web'
    legacy:
      prismjs: 'Prism'
