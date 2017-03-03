import path from 'path'

import rollup      from 'rollup'
import builtins    from 'rollup-plugin-node-builtins'
import coffee      from 'rollup-plugin-coffee-script'
import commonjs    from 'rollup-plugin-commonjs'
import filesize    from 'rollup-plugin-filesize'
import globals     from 'rollup-plugin-node-globals'
import nodeResolve from 'rollup-plugin-node-resolve'
import sourcemaps  from 'rollup-plugin-sourcemaps'

import Bundle from './bundle'
import {merge} from './utils'

cache     = null
SOURCEMAP = process.env.SOURCEMAP ? false


class Handroll
  constructor: (opts) ->
    return new Handroll opts unless @ instanceof Handroll
    @init opts if opts?

  init: (opts = {}) ->
    opts.browser    ?= false
    opts.extensions ?= ['.js', '.coffee']
    opts.sourceMap  ?= (SOURCEMAP ? false)
    opts.pkg        ?= require path.join process.cwd(), 'package.json'

    if opts.external
      opts.external = @getExternal opts.pkg
      console.log 'found external packages', opts.external
    else
      console.log 'fuck you'

    opts.plugins = opts.plugins ? @plugins opts
    opts.acorn  ?= allowReserved: true
    @opts = opts

  plugins: merge (opts) ->
    plugins = [
      sourcemaps()
      coffee()
    ]

    if opts.commonjs
      plugins.push builtins()
      plugins.push globals()
      plugins.push commonjs
        extensions: opts.extensions
        sourceMap:  opts.sourceMap

    plugins.push nodeResolve
      browser:    opts.browser
      extensions: opts.extensions
      module:     true
      jsnext:     true

    if opts.strip
      plugins.push strip
        debugger:  true
        functions: ['console.log', 'assert.*', 'debug', 'alert']
        sourceMap: opts.sourceMap

    unless opts.quiet
      plugins.push filesize()

    plugins

  getExternal: (pkg) ->
    deps    = Object.keys pkg.dependencies
    devDeps = Object.keys pkg.devDependencies
    deps.concat devDeps

  bundle: (opts) ->
    @init opts if opts?

    new Promise (resolve, reject) ->
      rollup.rollup
        acorn:      opts.acorn
        entry:      opts.entry
        external:   opts.external
        plugins:    opts.plugins
        sourceMap:  opts.sourceMap
        cache:      cache
      .then (bundle) ->
        console.log 'bundled', opts.entry
        resolve new Bundle bundle, opts
      .catch (err) ->
        if err.plugin? and err.id?
          console.error "Plugin '#{err.plugin}' failed on module #{err.id}"
        reject err

  bundleExternal: merge (opts) ->
    opts.external = true
    @bundle opts


export default Handroll
