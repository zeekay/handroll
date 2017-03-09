import fs from 'fs'

import {moduleName} from './utils'


export detectFormat = (opts) ->
  # Default to es module
  opts.format ?= 'es'

  switch opts.format
    when 'app'
      app opts
    when 'bin', 'binary', 'executable'
      bin opts
    when 'cjs', 'commonjs', 'node'
      cjs opts
    when 'es',  'module'
      es opts
    when 'web', 'iife'
      web opts
    else
      throw new Error 'Unsupported export format'

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


export bin = (opts) ->
  dest = opts.dest ? opts.pkg.main ? 'index.js'

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
