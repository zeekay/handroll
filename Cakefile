require 'shortcake'

use 'cake-bundle'
use 'cake-outdated'
use 'cake-publish'
use 'cake-test'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'bootstrap', 'bootstrap project', ->
  bundle.write
    entry:    'src/index.coffee'
    dest:     'dist/bootstrap.js'
    format:   'cjs'
    external: true

task 'build', 'build project', ['bootstrap'], ->
  handroll = require './dist/bootstrap'

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
