import path     from 'path'
import {rollup} from 'rollup'

import log from './log'
import {autoExternal}            from './external'
import {autoFormats, formatOpts} from './formats'
import {autoPlugins}             from './plugins'
import {banner, merge}           from './utils'
import {generate}                from './generate'
import {write, writeAll}         from './write'

cached = null

readPkg = ->
  try
    require path.join process.cwd(), 'package.json'
  catch err
    {}

class Bundle
  constructor: (opts = {}) ->
    return new Bundle opts unless @ instanceof Bundle

    opts.pkg ?= readPkg()

    opts.acorn      ?= allowReserved: true
    opts.browser    ?= false
    opts.compilers  ?= null
    opts.es3        ?= false
    opts.executable ?= false
    opts.extensions ?= ['.js', '.coffee', '.pug', '.styl']
    opts.sourceMap  ?= true

    opts.external   ?= null
    opts.include    ?= []
    opts.inject     ?= null
    opts.plugins    ?= null
    opts.use        ?= []

    log.verbose not (opts.quiet ? false)

    @opts = opts

  cache: ({cache, invalidate}) ->
    return null if cache == false

    cache ?= cached

    if invalidate?
      for id in invalidate
        log "removing #{id} from module cache"
        delete cache[id]

    cache

  rollup: merge (opts) ->
    unless opts.input? and opts.input != ''
      throw new Error 'No input module specified'

    banner()

    if @bundle?
      log 'using cached bundle'
      return Promise.resolve @bundle

    opts.autoExternal = opts.autoExternal ? opts.external == true
    opts.basedir      = opts.basedir      ? path.dirname opts.input

    # Detect format and update opts accordingly
    opts.formats = autoFormats opts
    if opts.formats.length == 1
      opts.format = opts.formats[0]

    # Set a few overrides if a single format is selected
    if opts.format?
      for k, v of (formatOpts opts)
        opts[k] = v

    opts.external = autoExternal opts
    opts.plugins  = autoPlugins opts

    new Promise (resolve, reject) =>
      rollup
        input:     opts.input
        cache:     @cache opts
        acorn:     opts.acorn
        external:  opts.external
        plugins:   opts.plugins
        sourcemap: opts.sourceMap
        onwarn:    (warning) ->
          return if warning.code == 'UNRESOLVED_IMPORT'
          return opts.onwarn warning if opts.onwarn?
          log.warn warning.message

      .then (bundle) =>
        @bundle = bundle if opts.cacheBundle
        resolve bundle
        log.white.bold opts.input

      .catch (err) =>
        if err.loc?.file?
          log "\nFailed to parse '#{err.loc.file}'"
          log "\n#{err.frame}\n" if err.frame?
        else if err.plugin? and err.id?
          log "\nPlugin '#{err.plugin}' failed on module #{err.id}"
          log err.stack
        else if err.id?
          log "\nFailed to parse module #{err.id}"
          log err.stack
        else
          log err.stack
        reject err

  generate: merge (opts) ->
    new Promise (resolve, reject) =>
      @rollup opts
        .then (bundle) ->
          resolve generate bundle, opts
        .catch reject

  write: merge (opts) ->
    new Promise (resolve, reject) =>
      @rollup opts
        .then (bundle) ->
          if opts.format?
            resolve write bundle, opts
          else
            resolve writeAll bundle, opts
        .catch reject

export default Bundle
