import {merge, moduleName} from './utils'

class Bundle
  constructor: (@bundle, @opts = {}) ->

  write: (opts = {}) ->
    opts = merge @opts, opts

    # Default to es module format
    opts.format ?= 'app'

    switch opts.format
      when 'esmodule', 'es'
        @writeModule opts
      when 'browser', 'iife'
        @writeBrowser opts
      when 'node',    'cjs'
        @writeCommonJS opts

  writeApp: merge (opts) ->

  writeModule: merge (opts) ->
    @bundle.write
      dest:      opts.pkg.module
      format:    'es'
      sourceMap: opts.sourceMap

  writeBrowser: merge (opts) ->
    @bundle.write
      dest:       (moduleName opts.pkg.name) + '.js'
      format:     'iife'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

  writeCommonJS: merge (opts) ->
    @bundle.write
      dest:       opts.pkg.main
      format:     'cjs'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

export default Bundle
