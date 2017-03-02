import {merge, moduleName} from './utils'

class Bundle
  constructor: (@bundle, @opts = {}) ->
    console.log 'opts.pkg.name', @opts.pkg.name

  write: (opts = {}) ->
    opts = merge @opts, opts
    switch opts.format
      when 'es'
        @writeModule opts
      when 'iife'
        @writeBrowser opts
      when 'cjs'
        @writeCommonJS opts

  writeModule: (opts = {}) ->
    opts = merge @opts, opts
    @bundle.write
      dest:      opts.pkg.module
      format:    'es'
      sourceMap: opts.sourceMap

  writeBrowser: (opts = {}) ->
    opts = merge @opts, opts
    @bundle.write
      dest:       (moduleName opts.pkg.name) + '.js'
      format:     'iife'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

  writeCommonJS: (opts = {}) ->
    opts = merge @opts, opts
    @bundle.write
      dest:       opts.pkg.main
      format:     'cjs'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

export default Bundle
