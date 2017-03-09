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
  formats:    []

  commonjs:   false
  dest:       null
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
    when '--format', '--fmt'
      opts.formats.push args.shift()
    when '--module-name'
      opts.moduleName = args.shift()
    when '--source-map'
      opts.sourceMap = true
    else
      error "Unrecognized option: '#{opt}'"

unless opts.formats.length
  opts.format = 'es'

bundle = handroll.bundle
  commonjs:   opts.commonjs
  entry:      opts.entry
  moduleName: opts.moduleName

for fmt in opts.formats
  bundle.write
    format: fmt
    dest:   opts.dest
