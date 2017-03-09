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
    --format      Format to output
    --commonjs    Enable CommonJS support
    --source-map  Enable source map support
    --version     Print version information
    --help        Print this usage
  """
  process.exit 0

opts =
  commonjs:  false
  entry:     null
  format:    'es'
  sourceMap: false

args = process.argv.slice 2
opts.entry = args.shift()

while opt = args.shift()
  switch opt
    when '--format'
      opts.format = args.shift()
    when '--commonjs'
      opts.commonjs = true
    when '--source-map'
      opts.sourceMap = false
    else
      error "Unrecognized option: '#{opt}'"

handroll.bundle
  entry: opts.entry, commonjs: opts.commonjs
.then (bundle) ->
  result = bundle.write format: opts.format
  console.log result.code
.catch (err) ->
  console.log err.stack
