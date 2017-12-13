import fs   from 'fs'
import path from 'path'

import {isString, moduleName} from './utils'

nameFromPkg = (opts) ->
  moduleName opts.pkg?.name

# autoFormat tries to guess the formats required for an operation based on your
# package.json file. If opts.format is specified, multiple formats will not be
# considered.
export autoFormats = ({format, formats, pkg}) ->
  if format?
    [format]
  else if formats?
    formats
  else
    formats = []
    if pkg.browser?
      formats.push 'web'
    if pkg.main?
      formats.push 'cjs'
    if pkg.module?
      formats.push 'es'
    formats

# Detect formats requested
export detectFormats = (opts) ->
  # opts.format overrides opts.formats
  if opts.format?
    [opts.format]
  else if opts.formats?
    opts.formats
  else
    autoFormats opts

# Convert our formats to Rollup settings
export formatOpts = (opts) ->
  # Default to es module
  opts.format ?= 'cjs'

  switch opts.format
    when 'app'
      app opts
    when 'cli', 'bin', 'binary', 'executable'
      cli opts
    when 'cjs', 'commonjs', 'node'
      cjs opts
    when 'es',  'module'
      es opts
    when 'umd'
      umd opts
    when 'web', 'iife'
      web opts
    else
      throw new Error 'Unsupported export format'

# Various pre-configurations we support
export app = (opts) ->
  output = opts.output ? opts.pkg?.app ? opts.pkg?.main

  stat = fs.statSync output

  if stat.isDirectory()
    output = path.join output, 'app.js'

  file:      output
  format:    'iife'
  sourcemap: opts.sourceMap

export es = (opts) ->
  output = opts.output ? opts.pkg?.module ? opts.pkg?['js:next'] ? 'index.mjs'

  file:      output
  format:    'es'
  sourcemap: opts.sourceMap

export cjs = (opts) ->
  output = opts.output ? opts.pkg?.main ? 'index.js'

  file:       output
  format:     'cjs'
  sourcemap:  opts.sourceMap

export cli = (opts) ->
  output = opts.output ? opts.pkg?.bin ? path.join 'bin/', (nameFromPkg opts).toLowerCase()

  # Sometimes bin is an object, use the first mapping here
  unless isString output
    output = output[(Object.keys output)[0]]

  file:       output
  format:     'cjs'
  executable: true
  sourcemap:  opts.sourceMap

export web = (opts) ->
  name   = opts.name   ? nameFromPkg opts
  output = opts.output ? "#{name}.js".toLowerCase()

  file:       output
  format:     'iife'
  browser:    opts.browser != false
  external:   false
  name:       name
  sourcemap:  opts.sourceMap

export umd = (opts) ->
  file:       opts.output
  format:     'umd'
  sourcemap:  opts.sourceMap
