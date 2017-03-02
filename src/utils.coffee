# Create a merged copy of a set of objects
export merge = (fn) ->
  (opts = {}) ->
    fn.call @, (Object.assign {}, @opts, opts)

# Try to guess moduleName (used in export for browser bundles)
export moduleName = (name) ->
  first = name.charAt(0).toUpperCase()
  name  = name.replace /\.js$|\.coffee$|-js$/, ''
  first + name.slice 1
