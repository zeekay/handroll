import path from 'path'

import commonjs     from 'rollup-plugin-commonjs'
import es3          from 'rollup-plugin-es3'
import executable   from 'rollup-plugin-executable'
import inject       from 'rollup-plugin-inject'
import legacy       from 'rollup-plugin-legacy'
import sizes        from 'rollup-plugin-sizes'
import sourcemaps   from 'rollup-plugin-sourcemaps'
import shebang      from 'rollup-plugin-shebang'
import nodeResolve  from '@zeekay/rollup-plugin-node-resolve'

import autoCompilers from '../compilers'
import log           from '../log'

import annotate      from './annotate'
import builtins      from './builtins'
import filesize      from './filesize'
import globals       from './globals'
import minify        from './minify'


resolveId = (id, opts = {}) ->
  if opts.browser
    nodeResolve.browser.sync id, basedir: opts.basedir
  else
    nodeResolve.node.sync id, basedir: opts.basedir


export autoPlugins = (opts) ->
  # Start with source map support
  plugins = [sourcemaps()]

  # Detect compiler plugins or used passed plugins
  if opts.plugins?
    plugins = plugins.concat opts.plugins
  else
    for k,v of autoCompilers opts
      plugins.push v

  # Load up any extra plugins specified
  plugins = plugins.concat (opts.use ? [])

  # Add extra info above each module in bunlde
  plugins.push annotate sourcemap: opts.sourcemap

  # Enable legacy
  if opts.legacy?
    for k,v of opts.legacy
      try
        # Attempt to automatically resolve path to legacy files
        opts.legacy[resolveId k, opts] = v
      catch err
    plugins.push legacy opts.legacy

  # Enable node builtins in browser
  if opts.builtins or opts.browser and opts.builtins != false
      plugins.push builtins()

  # Automatically resolve node modules
  plugins.push nodeResolve
    basedir:        opts.basedir
    browser:        opts.browser
    extensions:     opts.extensions
    preferBuiltins: opts.preferBuiltins
    external:       opts.autoExternal ? true
    skip:           opts.skip         ? opts.external

  # Enable node globals in browser
  if opts.globals or opts.browser and opts.globals != false
      plugins.push globals()

  # Slightly more ES3 compatible output
  if opts.es3 or opts.browser and opts.es3 != false
    plugins.push es3()

  # Enable CommonJS
  if opts.commonjs
    plugins.push commonjs Object.assign
      extensions: opts.extensions
      sourceMap:  opts.sourcemap
    , opts.commonjs

  # Inject imports
  if opts.inject?
    plugins.push inject opts.inject

  # Automatically make bundle executable
  if opts.executable
    plugins.push shebang()
    plugins.push executable()

  # Strip any debugging logic
  if opts.strip
    plugins.push strip
      debugger:  true
      functions: ['console.log', 'assert.*', 'debug', 'alert']
      sourcemap: opts.sourcemap

  if opts.minify? and opts.minify != false
    plugins.push minify Object.assign {}, (source ap: opts.sourcemap), opts.minify

  # Extra logging + details
  unless opts.quiet
    plugins.push filesize()
    if opts.details
      plugins.push sizes details: true

  log 'plugins:'
  for plugin in plugins
    name = (plugin.name ? '').replace /rollup-plugin-/, ''
    log " + #{name}"

  plugins
