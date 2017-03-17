import fs    from 'fs'
import path  from 'path'

import chalk from 'chalk'
import rollup from 'rollup'

import plugins from './plugins'
import {log, merge} from './utils'
import {detectFormat, detectFormats} from './format'


cached = null

getExternal = (pkg, dev = false) ->
  deps    = Object.keys pkg.dependencies    ? {}
  devDeps = Object.keys pkg.devDependencies ? {}

  if dev
    deps.concat devDeps
  else
    deps

writeApp = (opts) ->
  opts = detectFormat opts
  fs.writeFileSync (path.join opts.basedir, 'index.html'), """
    <!DOCTYPE html>
    <html lang="en">
      <body>
        <script src="#{opts.dest}"></script>
      </body>
    </html>
    """
  opts

generate = (bundle, opts) ->
  bundle.generate detectFormat opts

write = (bundle, opts) ->
  switch opts.format
    when 'app'
      bundle.write writeApp opts
    else
      bundle.write detectFormat opts


class Bundle
  constructor: (@opts = {}) ->
    return new Bundle @opts unless @ instanceof Bundle

  log:     -> log.apply     @, arguments
  plugins: -> plugins.apply @, arguments

  cache: ({cache, invalidate}) ->
    cache ?= cached

    if invalidate?
      @log 'pruning cache object'
      for id in invalidate
        delete cache[id]

    cache

  rollup: merge (opts) ->
    unless opts.entry? and opts.entry != ''
      throw new Error 'No entry module specified'

    if @bundle?
      @log 'using cached bundle'
      return Promise.resolve @bundle

    @log 'rolling up'

    external = opts.external ? []
    if opts.external == true
      external = getExternal opts.pkg

    if external.length
      @log 'external:'
      for dep in external
        @log " - #{dep}"

    new Promise (resolve, reject) =>
      rollup.rollup
        external:  external

        acorn:     opts.acorn
        entry:     opts.entry
        sourceMap: opts.sourceMap
        cache:     @cache opts
        plugins:   @plugins opts

      .then (bundle) =>
        @bundle = bundle if opts.cacheBundle
        resolve bundle
        @log chalk.white.bold opts.entry

      .catch (err) =>
        if err.loc?.file?
          @log "Failed to parse '#{err.loc.file}'"
          @log err.stack
        else if err.plugin? and err.id?
          @log "Plugin '#{err.plugin}' failed on module #{err.id}"
          @log err.stack
        else if err.id?
          @log "Failed to parse module #{err.id}:"
          @log err.stack
        else
          @log err.stack
        reject err

  rollupFormats: (opts, fn) ->
    @rollup opts
      .then (bundle) =>
        ps      = []
        formats = detectFormats opts

        for fmt in formats
          ps.push fn bundle, Object.assign {}, opts, format: fmt

        Promise.all ps

      .catch (err) ->
        reject err

  generate: merge (opts) ->
    @rollupFormats opts, generate

  write: merge (opts) ->
    @rollupFormats opts, write

export default Bundle
