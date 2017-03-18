import log from './log'

# Create a merged copy of a set of objects
export merge = (fn) ->
  (opts) ->
    opts = (Object.assign {}, @opts, opts)
    log.verbose !opts.quiet if opts.quiet?
    fn.call @, opts

# Try to guess moduleName (used in export for browser bundles)
export moduleName = (name) ->
  first = name.charAt(0).toUpperCase()
  name  = name.replace /\.js$|\.coffee$|-js$/, ''
  name  = name.replace /-([a-z])/g, (g) -> g[1].toUpperCase()
  first + name.slice 1

export enableAsync = ->
  version = process.versions.v8.match /^([0-9]+)\.([0-9]+)\./
  major   = parseInt version[1], 10
  minor   = parseInt version[2], 10

  if major < 5 or (major == 5 and minor < 4)
    # not supported
    throw new Error 'async/await is not supported in V8 versions before 5.4'

  if major > 5 or (major == 5 and minor > 4)
    # enabled by default
    return

  v8.setFlagsFromString '--harmony_async_await'


export isPlugin = do ->
  keys = new Set [
    'name'
    'options'
    'load'
    'resolveId'
    'transform'
    'transformBundle'
    'ongenerate'
    'onwrite'
    'intro'
    'outro'
    'banner'
    'footer'
  ]

  (obj) ->
    for own k of obj
      if keys.has k
        return true
    false
