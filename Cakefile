require 'shortcake'

use 'cake-bundle'
use 'cake-outdated'
use 'cake-publish'
use 'cake-test'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ->
  b = yield bundle
    entry:    'src/index.coffee'
    external: true

  yield b.write formats: ['cjs', 'es']

  yield bundle.write
    entry:      'src/cli.coffee'
    format:     'cli'
    executable: true
    external:   true
    sourceMap:  false

task 'watch', 'watch project and build on changes', ->
  build = (filename) ->
    console.log filename, 'modified, rebuilding'
    invoke 'build' if not running 'build'
  watch 'src/',          build
  watch 'node_modules/', build, watchSymlink: true

task 'test', 'test handroll', ['build']
