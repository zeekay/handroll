import coffee      from 'rollup-plugin-coffee-script'
import commonjs    from 'rollup-plugin-commonjs'
import nodeResolve from 'rollup-plugin-node-resolve'
import rollup      from 'rollup'

SOURCEMAP = process.env.SOURCEMAP ? false

# Try to guess moduleName (used in export for browser bundles)
moduleName = (name) ->
  first = name.charAt(0).toUpperCase()
  name = name.replace /\.js$|\.coffee$|-js$/, ''
  first + name.slice 1

class Handroll
  constructor: (opts = {}) ->
    @pkg     = opts.pkg ? require path.join process.cwd(), 'package.json'
    @plugins = opts.plugins ? @plugins opts

  plugins: (opts = {}) ->
    sourceMap = opts.sourceMap ? SOURCEMAP ? false

    [
      coffee()
      nodeResolve
        browser: true
        extensions: ['.js', '.coffee']
        module:  true
      commonjs
        extensions: ['.js', '.coffee']
        sourceMap: sourceMap
    ]

  bundle: (opts = {}) ->
    unless opts.entry?
      throw new Error 'entry must be specified'
    opts.plugins = opts.plugins ? @plugins opts
    rollup.rollup opts

  bundleExternal: (opts = {}) ->
    opts.external = Object.keys @pkg.dependencies
    @bundle opts

  writeBrowser: ->
    bundle.write
      dest:       @pkg.name + '.js'
      format:     'iife'
      moduleName: moduleName @pkg.name

  writeCommonJS: ->
    bundle.write
      dest:       @pkg.main
      format:     'cjs'
      moduleName: moduleName @pkg.name
      sourceMap:  'inline'

  write: ->
    bundle.write
      dest:      @pkg.module
      format:    'es'
      sourceMap: 'inline'

handroll = new Handroll()
handroll.Handroll = Handroll
export default handroll
