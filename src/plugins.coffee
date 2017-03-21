import path from 'path'

import builtins    from 'rollup-plugin-node-builtins'
import commonjs    from 'rollup-plugin-commonjs'
import es3         from 'rollup-plugin-es3'
import executable  from 'rollup-plugin-executable'
import globals     from 'rollup-plugin-node-globals'
import nodeResolve from 'rollup-plugin-node-resolve-magic'
import sizes       from 'rollup-plugin-sizes'
import sourcemaps  from 'rollup-plugin-sourcemaps'
import legacy      from 'rollup-plugin-legacy'

import annotate    from './plugins/annotate'
import filesize    from './plugins/filesize'
import minify      from './plugins/minify'
import shebang     from './plugins/shebang'

import autoCompilers from './compilers'
import log           from './log'


resolve = (id, opts = {}) ->
  if opts.browser
    nodeResolve.browser.sync id, basedir: opts.basedir
  else
    nodeResolve.node.sync id, basedir: opts.basedir


export autoPlugins = (opts) ->
  # Start with source map support
  plugins = [sourcemaps()]

  if opts.plugins?
    plugins = plugins.concat opts.plugins
  else
    for k,v of autoCompilers opts
      plugins.push v

  # Load up any extra plugins specified
  plugins = plugins.concat (opts.use ? [])

  # Add extra info above each module in bunlde
  plugins.push annotate sourceMap: opts.sourceMap

  # Automatically resolve node modules
  plugins.push nodeResolve
    basedir:        opts.basedir
    browser:        opts.browser
    extensions:     opts.extensions
    preferBuiltins: opts.preferBuiltins
    external:       opts.autoExternal ? true
    skip:           opts.skip         ? []

  # Enable legacy
  if opts.legacy?
    # Attempt to automatically resolve path to node module
    for k,v of opts.legacy
      try
        pkg = resolve k, opts
        delete opts.legacy[k]
        opts.legacy[pkg] = v
      catch err
    plugins.push legacy opts.legacy

  # Enable CommonJS
  if opts.commonjs
    plugins.push builtins()
    plugins.push globals()
    plugins.push commonjs Object.assign
      extensions: opts.extensions
      sourceMap:  opts.sourceMap
    , opts.commonjs

  # Support ES3 on end
  if opts.es3
    plugins.push es3()

  # Automatically make bundle executable
  if opts.executable
    plugins.push shebang()
    plugins.push executable()

  # Strip any debugging logic
  if opts.strip
    plugins.push strip
      debugger:  true
      functions: ['console.log', 'assert.*', 'debug', 'alert']
      sourceMap: opts.sourceMap

  if opts.minify
    plugins.push minify()

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
