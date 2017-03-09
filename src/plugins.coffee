import builtins    from 'rollup-plugin-node-builtins'
import commonjs    from 'rollup-plugin-commonjs'
import es3         from 'rollup-plugin-es3'
import executable  from 'rollup-plugin-executable'
import globals     from 'rollup-plugin-node-globals'
import nodeResolve from 'rollup-plugin-node-resolve'
import sizes       from 'rollup-plugin-sizes'
import sourcemaps  from 'rollup-plugin-sourcemaps'

import compilers from './compilers'
import annotate  from './plugins/annotate'
import filesize  from './plugins/filesize'
import minify    from './plugins/minify'
import shebang   from './plugins/shebang'


export default (opts) ->
  # Start with source map support
  plugins = [sourcemaps()]

  if opts.plugins?
    for plugin in opts.plugins
      plugins.push plugin
  else
    # Add compilers
    for k,v of compilers opts
      plugins.push v

  # Load up any extra plugins specified
  for plugin in opts.use
    plugins.push plugin

  # Add extra info above each module in bunlde
  plugins.push annotate
    sourceMap: opts.sourceMap

  # Automatically resolve node modules
  plugins.push nodeResolve
    browser:        opts.browser
    extensions:     opts.extensions
    module:         true
    jsnext:         true
    preferBuiltins: opts.preferBuiltins ? true

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

  plugins
