import path from 'path'

import commonjs     from 'rollup-plugin-commonjs'
import es3          from 'rollup-plugin-es3'
import executable   from 'rollup-plugin-executable'
import legacy       from 'rollup-plugin-legacy'
import nodeResolve  from 'rollup-plugin-node-resolve-magic'
import sizes        from 'rollup-plugin-sizes'
import sourcemaps   from 'rollup-plugin-sourcemaps'

import annotate    from './plugins/annotate'
import builtins    from './plugins/builtins'
import filesize    from './plugins/filesize'
import globals     from './plugins/globals'
import minify      from './plugins/minify'
import shebang     from './plugins/shebang'

import autoCompilers from './compilers'
import log           from './log'


resolveId = (id, opts = {}) ->
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

  # Enable legacy
  if opts.legacy?
    for k,v of opts.legacy
      try
        # Attempt to automatically resolve path to legacy files
        opts.legacy[resolveId k, opts] = v
      catch err
    plugins.push legacy opts.legacy

  # Enable node modules in browser
  if opts.browser or opts.node
    plugins.push globals()
    plugins.push builtins()

  # Automatically resolve node modules
  plugins.push nodeResolve
    basedir:        opts.basedir
    browser:        opts.browser
    extensions:     opts.extensions
    preferBuiltins: opts.preferBuiltins
    external:       opts.autoExternal ? true
    skip:           opts.skip         ? opts.external

  # Slightly more ES3 compatible output
  if opts.browser or opts.es3
    plugins.push es3()

  # Enable CommonJS
  if opts.commonjs
    plugins.push commonjs Object.assign
      extensions: opts.extensions
      sourceMap:  opts.sourceMap
    , opts.commonjs

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
    if name == ""
      console.log plugin.resolveId.toString()
    log " + #{name}"

  plugins
