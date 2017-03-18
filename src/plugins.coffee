import path from 'path'

import builtins    from 'rollup-plugin-node-builtins'
import commonjs    from 'rollup-plugin-commonjs'
import es3         from 'rollup-plugin-es3'
import executable  from 'rollup-plugin-executable'
import globals     from 'rollup-plugin-node-globals'
import nodeResolve from 'rollup-plugin-node-resolve-magic'
import sizes       from 'rollup-plugin-sizes'
import sourcemaps  from 'rollup-plugin-sourcemaps'

import annotate    from './plugins/annotate'
import filesize    from './plugins/filesize'
import minify      from './plugins/minify'
import shebang     from './plugins/shebang'

import autoCompilers from './compilers'
import log           from './log'

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
    basedir:        opts.basedir ? path.dirname opts.entry
    browser:        opts.browser
    extensions:     opts.extensions
    preferBuiltins: opts.preferBuiltins

  # Enable CommonJS
  if opts.commonjs
    plugins.push builtins()
    plugins.push globals()
    plugins.push commonjs
      extensions: opts.extensions
      sourceMap:  opts.sourceMap

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
    log " - #{plugin.name}"

  plugins
