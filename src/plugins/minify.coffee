import { minify } from 'uglify-js'

export default (opts = {}) ->
  name: 'minify'

  transformBundle: (code, plugins, sourceMapChain, options) ->
    if opts.sourceMap
      mapPath = opts.sourceMapPath ? opts.dest + '.map'
    else
      mapPath = null

    result = minify code, fromString: true, outSourceMap: mapPath, outFileName: opts.dest

    # Strip sourcemaps comment and extra \n
    if result.map
        commentPos  = result.code.lastIndexOf '//#'
        result.code = result.code.slice(0, commentPos).trim()
    else
      result.map = mappings: ''

    result
