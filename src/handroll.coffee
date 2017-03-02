import path    from 'path'
import Promise from 'broken'

import builtins    from 'rollup-plugin-node-builtins'
import coffee      from 'rollup-plugin-coffee-script'
import commonjs    from 'rollup-plugin-commonjs'
import filesize    from 'rollup-plugin-filesize'
import globals     from 'rollup-plugin-node-globals'
import nodeResolve from 'rollup-plugin-node-resolve'
import rollup      from 'rollup'

import Bundle from './bundle'
import {merge} from './utils'

cache     = null
SOURCEMAP = process.env.SOURCEMAP ? false


class Handroll
  constructor: (opts = {}) ->
    opts.browser    ?= false
    opts.extensions ?= ['.js', '.coffee']
    opts.sourceMap  ?= (SOURCEMAP ? false)
    opts.pkg        ?= require path.join process.cwd(), 'package.json'
    @opts = opts

  plugins: merge (opts) ->
    plugins = [
      builtins()
      globals()
      coffee()
      nodeResolve
        browser:    opts.browser
        extensions: opts.extensions
        module:     true
      commonjs
        extensions: opts.extensions
        sourceMap:  opts.sourceMap
    ]

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

  bundle: merge (opts) ->
    if opts.external == true
      opts.external = @getExternal opts.pkg

    opts.plugins = opts.plugins ? @plugins opts
    opts.acorn  ?= allowReserved: true

    new Promise (resolve, reject) ->
      rollup.rollup
        acorn:      opts.acorn
        cache:      cache
        entry:      opts.entry
        external:   opts.external
        plugins:    opts.plugins
        sourceMap:  opts.sourceMap
      .then (bundle) ->
        resolve new Bundle bundle, opts
      .catch reject

  bundleExternal: merge (opts) ->
    opts.external = true
    @bundle opts

export default Handroll
