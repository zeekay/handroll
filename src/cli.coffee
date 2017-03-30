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
    --dest,   -o   Destination to write output
    --format, -f   Format to output
    --formats      Comma separated list of formats to output
    --es           ES module format
    --cjs          CommonJS module format
    --cli          Executable format
    --web          Web format
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

    when '--dest', '--out', '-o'
      opts.dest = args.shift()

    when '--format', '--formats', '-f'
      for fmt in args.shift().split ','
        opts.formats.push fmt

    # Various module format shorthands
    when '--es'
      opts.formats.push 'es'
    when '--cjs'
      opts.formats.push 'cjs'
    when '--cli'
      opts.formats.push 'cli'
    when '--web'
      opts.formats.push 'web'

    when '--module-name'
      opts.moduleName = args.shift()

    when '--source-map'
      opts.sourceMap = true
    when '--no-source-map'
      opts.sourceMap = false

    when '--version', '-v', 'version'
      version()
    else
      if /^-/.test opt
        error "Unrecognized option: '#{opt}'"
      else
        opts.entry = opt

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
