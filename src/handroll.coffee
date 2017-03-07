import path from 'path'

# monkey-patch rollup
import rollup from 'rollup'
import time   from 'rollup-timer'
time(rollup)

# import buble       from 'rollup-plugin-buble'
import builtins    from 'rollup-plugin-node-builtins'
import coffee      from 'rollup-plugin-coffee-script'
import commonjs    from 'rollup-plugin-commonjs'
import es3         from 'rollup-plugin-es3'
import filesize    from 'rollup-plugin-filesize'
import globals     from 'rollup-plugin-node-globals'
import json        from 'rollup-plugin-json'
import nodeResolve from 'rollup-plugin-node-resolve'
import pug         from 'rollup-plugin-pug'
import sizes       from 'rollup-plugin-sizes'
import sourcemaps  from 'rollup-plugin-sourcemaps'
import stylup      from 'rollup-plugin-stylup'

import autoprefixer from 'autoprefixer'
import chalk        from 'chalk';
import comments     from 'postcss-discard-comments'
import lost         from 'lost-stylus'
import postcss      from 'poststylus'
import rupture      from 'rupture'

import Bundle from './bundle'
import {merge} from './utils'

cache = null

sourceMapOverride = ->
 return false if process.env.DISABLE_SOURCEMAP
 return false if process.env.NO_SOURCEMAP
 return true  if process.env.SOURCEMAP
 null

class Handroll
  constructor: (opts) ->
    return new Handroll opts unless @ instanceof Handroll
    @init opts if opts?

  init: (opts = {}) ->
    opts.acorn      ?= allowReserved: true
    opts.browser    ?= false
    opts.es3        ?= false
    opts.extensions ?= ['.js', '.coffee', '.pug', '.styl']
    opts.pkg        ?= require path.join process.cwd(), 'package.json'
    opts.sourceMap  ?= sourceMapOverride() ? true
    opts.use        ?= []

    if opts.external
      opts.external = @getExternal opts.pkg
      console.log 'found external packages', opts.external

    opts.compilers  ?= {}
    opts.compilers.coffee ?= coffee()
    # opts.compilers.js     ?= buble
    opts.compilers.json   ?= json()
    opts.compilers.pug    ?= pug
      compileDebug:           true
      inlineRuntimeFunctions: false
      pretty:                 true
      sourceMap:              opts.sourceMap
      staticPattern:          /\S/
    opts.compilers.stylus ?= stylup
      sourceMap: opts.sourceMap
      plugins: [
        lost()
        rupture()
        postcss [
          'css-mqpacker'
          'lost'
          autoprefixer browsers: '> 1%'
          comments removeAll: true
        ]
      ]

    opts.plugins = opts.plugins ? @plugins opts

    @opts = opts

  plugins: merge (opts) ->
    plugins = [sourcemaps()]

    for k,v of opts.compilers
      plugins.push v

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

    plugins

  getExternal: (pkg) ->
    deps    = Object.keys pkg.dependencies
    devDeps = Object.keys pkg.devDependencies
    deps.concat devDeps

  bundle: (opts) ->
    @init opts if opts?

    plugins = opts.plugins

    for plugin in opts.use
      plugins.push plugin

    if opts.es3
      plugins.push es3()

    if opts.strip
      plugins.push strip
        debugger:  true
        functions: ['console.log', 'assert.*', 'debug', 'alert']
        sourceMap: opts.sourceMap

    unless opts.quiet
      plugins.push filesize
        # format:
        #   unix: true
        render: (_, size, gzip) ->
          gb = chalk.green.bold
          wb = chalk.white.bold
          """
          #{wb opts.entry} - #{gb size} (#{gb gzip} compressed)
          """

      plugins.push sizes details: opts.details ? true

    new Promise (resolve, reject) ->
      rollup.rollup
        acorn:      opts.acorn
        cache:      opts.cache ? cache
        entry:      opts.entry
        external:   opts.external
        plugins:    plugins
        sourceMap:  opts.sourceMap
      .then (bundle) ->
        console.log 'bundled', opts.entry
        resolve new Bundle bundle, opts
      .catch (err) ->
        unless err.plugin?
          console.error "Failed to parse module #{err.id}"
        if err.plugin? and err.id?
          console.error "Plugin '#{err.plugin}' failed on module #{err.id}"
        reject err

  bundleExternal: merge (opts) ->
    opts.external = true
    @bundle opts

  use: (plugin) ->
    if Array.isArray plugin
      plugins = plugin
    else
      plugins = [plugin]

    for plugin in plugins
      @opts.use.push plugin
    @


export default Handroll
