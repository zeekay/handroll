fs = require 'fs'
os = require 'os'

handroll = require '../'

error = (message) ->
  console.error message
  process.exit 1

version = ->
  console.log (require '../package.json').version
  process.exit 0

usage = ->
  console.log """
  handroll <entry> [options]

  Options:
    --commonjs     Enable CommonJS support
    --dest         Destination to write output
    --format       Format to output
    --module-name  Name to use for iife module
    --source-map   Enable source map support

    --version      Print version information
    --help         Print this usage
  """
  process.exit 0

opts =
  entry:      null

  commonjs:   false
  dest:       null
  format:     'es'
  moduleName: null
  sourceMap:  false

args = process.argv.slice 2
opts.entry = args.shift()

while opt = args.shift()
  switch opt
    when '--commonjs'
      opts.commonjs = true
    when '--dest'
      opts.dest = args.shift()
    when '--format'
      opts.format = args.shift()
    when '--module-name'
      opts.moduleName = args.shift()
    when '--source-map'
      opts.sourceMap = false
    else
      error "Unrecognized option: '#{opt}'"

handroll.bundle
  entry: opts.entry, commonjs: opts.commonjs
.then (bundle) ->
  bundle.write format: opts.format, dest: opts.dest
.catch (err) ->
  console.log err.stack
