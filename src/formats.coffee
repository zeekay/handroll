import fs from 'fs'

import {moduleName} from './utils'

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


export detectFormat = (opts) ->
  # Default to es module
  opts.format ?= 'es'

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

export detectFormats = (opts) ->
  # Default to single format if opts.format provided
  if opts.format?
    [opts.format]
  else
    formats = []
    for fmt in (opts.formats ? [])
      unless ~formats.indexOf fmt
        formats.push fmt
    formats

export app = (opts) ->
  dest = opts.dest ? opts.pkg.app ? opts.pkg.main

  stat = fs.statSync dest

  if stat.isDirectory()
    basedir = dest
    dest    = path.join dest, 'app.js'
  else
    basedir = path.dirname dest

  basedir:   basedir
  dest:      dest
  format:    'iife'
  sourceMap: opts.sourceMap

export es = (opts) ->
  dest = opts.dest ? opts.pkg.module ? opts.pkg['js:next'] ? 'index.mjs'

  dest:      dest
  format:    'es'
  sourceMap: opts.sourceMap


export cjs = (opts) ->
  dest = opts.dest ? opts.pkg.main ? 'index.js'

  dest:       dest
  format:     'cjs'
  sourceMap:  opts.sourceMap


export cli = (opts) ->
  dest = opts.dest ? opts.pkg.bin ? path.join 'bin/', (moduleName opts.pkg.name).toLowerCase()

  dest:       dest
  format:     'cjs'
  sourceMap:  opts.sourceMap


export web = (opts) ->
  name = opts.moduleName ? moduleName opts.pkg.name
  dest = opts.dest       ? "#{name}.js".toLowerCase()

  dest:       dest
  format:     'iife'
  moduleName: name
  sourceMap:  opts.sourceMap


export umd = (opts) ->
  dest:       opts.dest
  format:     'umd'
  sourceMap:  opts.sourceMap
