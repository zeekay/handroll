import path from 'path'

import Bundle  from './bundle'
import {merge} from './utils'


sourceMapOverride = ->
 return false if process.env.DISABLE_SOURCEMAP
 return false if process.env.NO_SOURCEMAP
 return true  if process.env.SOURCEMAP
 null


class Handroll
  constructor: (opts = {}) ->
    return new Handroll opts unless @ instanceof Handroll

    opts.acorn      ?= allowReserved: true
    opts.browser    ?= false
    opts.es3        ?= false
    opts.executable ?= false
    opts.external   ?= false
    opts.extensions ?= ['.js', '.coffee', '.pug', '.styl']
    opts.pkg        ?= require path.join process.cwd(), 'package.json'
    opts.sourceMap  ?= sourceMapOverride() ? true
    opts.use        ?= []
    opts.compilers  ?= null

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
      (bundle.rollup cache: true)
        .then -> resolve bundle

  generate: merge (opts) ->
    (new Bundle opts).generate()

  write: merge (opts) ->
    (new Bundle opts).write()


export default Handroll
