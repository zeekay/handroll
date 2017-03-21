import path from 'path'

import Bundle from './bundle'
import log from './log'
import {merge} from './utils'


sourceMapOverride = ->
 return false if process.env.DISABLE_SOURCEMAP
 return false if process.env.NO_SOURCEMAP
 return true  if process.env.SOURCEMAP
 null


class Handroll
  constructor: (opts = {}) ->
    return new Handroll opts unless @ instanceof Handroll

    opts.sourceMap ?= sourceMapOverride() ? true
    log.verbose not (opts.quiet ? false)
    @opts = opts

  use: (plugin) ->
    if Array.isArray plugin
      plugins = plugin
    else
      plugins = [plugin]

    for plugin in plugins
      @opts.use.push plugin
    @

  bundle: merge (opts) ->
    bundle = new Bundle opts
    new Promise (resolve, reject) ->
      (bundle.rollup cacheBundle: true)
        .then -> resolve bundle

  generate: merge (opts) ->
    (new Bundle opts).generate()

  write: merge (opts) ->
    (new Bundle opts).write()


export default Handroll
