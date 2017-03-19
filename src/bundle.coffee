import {rollup} from 'rollup'

import log from './log'

import {autoExternal}    from './external'
import {autoFormats}     from './formats'
import {autoPlugins}     from './plugins'
import {generate}        from './generate'
import {merge}           from './utils'
import {write, writeAll} from './write'

cached = null


class Bundle
  constructor: (@opts = {}) ->
    return new Bundle @opts unless @ instanceof Bundle

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

    if @bundle?
      log 'using cached bundle'
      return Promise.resolve @bundle

    opts.external = autoExternal opts
    opts.formats  = autoFormats opts
    opts.plugins  = autoPlugins opts

    new Promise (resolve, reject) =>
      log 'rolling up'

      rollup
        cache:     @cache opts
        acorn:     opts.acorn
        entry:     opts.entry
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
