import fs from 'fs'

import handroll from '../'
import pkg      from '../package.json'

error = (message) ->
  console.error message
  process.exit 1

version = ->
  console.log pkg.version
  process.exit 0

usage = ->
  console.log """
  handroll #{pkg.version}

  Usage:
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
    when '--version', '-v', 'version'
      console.log 'version'
      version()
    else
      if /^-/.test opt
        error "Unrecognized option: '#{opt}'"
      else
        opts.entry = opt

unless opts.formats.length
  opts.format = 'es'

unless opts.entry?
  usage()

handroll.bundle
  commonjs:   opts.commonjs
  entry:      opts.entry
  moduleName: opts.moduleName
.then (bundle) ->
  for fmt in opts.formats
    bundle.write
      format: fmt
      dest:   opts.dest
.catch (err) ->
  console.log err.stack
