require 'shortcake'

use 'cake-test'
use 'cake-publish'
use 'cake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ->
  bundle = yield handroll.bundle
    entry: src/index.coffee

  Promise.all [
    bundle.writeBrowser()
    bundle.writeCommonJS()
    bundle.write()
  ]
