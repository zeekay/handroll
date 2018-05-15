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
    handroll <input > [options]

  Options:
    --output, -o   Destination to write output
    --commonjs     Enable CommonJS support
    --format, -f   Format to output
    --formats      Comma separated list of formats to output
    --es           ES module format
    --cjs          CommonJS module format
    --cli          Executable format
    --web          Web format
    --browser      Bundle for browser
    --name         Name to use for IIFE module
    --source-map   Enable source map support
    --external     Modules to consider external
    --executable   Force executable mode
    --no-external  No modules should be external
    --minify       Enable minification

    --version      Print version information
    --help         Print this usage
  """
  process.exit 0

opts =
  input:      null
  formats:    []

  external:   null
  browser:    false
  commonjs:   false
  output:     ''
  name:       null
  sourcemap:  true
  minify:     false

args = process.argv.slice 2

while opt = args.shift()
  switch opt
    when '--commonjs'
      opts.commonjs = true

    when '--output', '--out', '-o'
      opts.output = args.shift()

    when '--format', '--formats', '-f'
      for fmt in args.shift().split ','
        opts.formats.push fmt

    when '--external'
      opts.external = args.shift().split ','
    when '--no-external'
      opts.external = false

    when '--executable'
      opts.executable = true
    when '--no-executable'
      opts.executable = false

    # Various module format shorthands
    when '--es'
      opts.formats.push 'es'
    when '--cjs'
      opts.formats.push 'cjs'
    when '--cli'
      opts.formats.push 'cli'
    when '--web'
      opts.formats.push 'web'

    when '--name', '--module-name'
      opts.name = args.shift()

    when '--browser'
      opts.browser = true

    when '--source-map', '--sourcemap'
      opts.sourcemap = true
    when '--no-source-map', '--no-sourcemap'
      opts.sourcemap = false

    when '--minify'
      opts.minify = true

    when '--help',    '-u', 'help'
      usage()
    when '--version', '-v', 'version'
      version()
    else
      if /^-/.test opt
        error "Unrecognized option: '#{opt}'"
      else
        opts.input = opt

unless opts.input?
  usage()

handroll.bundle
  input:      opts.input
  commonjs:   opts.commonjs
  format:     opts.format
  formats:    opts.formats
  minify:     opts.minify
  name:       opts.name
  sourcemap:  opts.sourcemap
.then (bundle) ->
  unless opts.formats.length > 0
    return bundle.write
      format: 'es'
      output: opts.output

  for fmt in opts.formats
    bundle.write
      format: fmt
      output: opts.output
.catch (err) ->
  console.log err.stack
