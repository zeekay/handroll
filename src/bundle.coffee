import path     from 'path'
import {rollup} from 'rollup'

import log from './log'
import {autoExternal}    from './external'
import {autoFormats}     from './formats'
import {autoPlugins}     from './plugins'
import {generate}        from './generate'
import {banner, merge}   from './utils'
import {write, writeAll} from './write'

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

    # These formats have specific meanings
    if opts.format == 'web'
      opts.browser  = true
      opts.external = false

    if opts.format == 'cli'
      opts.executable = true

    opts.acorn      ?= allowReserved: true
    opts.browser    ?= false
    opts.compilers  ?= null
    opts.es3        ?= false
    opts.executable ?= false
    opts.extensions ?= ['.js', '.coffee', '.pug', '.styl']
    opts.sourceMap  ?= true

    opts.external   ?= null
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
    unless opts.entry? and opts.entry != ''
      throw new Error 'No entry module specified'

    banner()

    if @bundle?
      log 'using cached bundle'
      return Promise.resolve @bundle

    opts.autoExternal = opts.autoExternal ? opts.external == true
    opts.basedir      = opts.basedir      ? path.dirname opts.entry
    opts.external     = autoExternal opts
    opts.formats      = autoFormats opts
    opts.plugins      = autoPlugins opts

    new Promise (resolve, reject) =>
      rollup
        entry:     opts.entry

        cache:     @cache opts

        acorn:     opts.acorn
        external:  opts.external
        plugins:   opts.plugins
        sourceMap: opts.sourceMap

        onwarn:    ({message}) ->
          return if /external dependency/.test message
          log.error message

      .then (bundle) =>
        @bundle = bundle if opts.cacheBundle
        resolve bundle
        log.white.bold opts.entry

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
