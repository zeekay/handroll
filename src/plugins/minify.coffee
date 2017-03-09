import { minify } from 'uglify-js'

export default (opts = {}) ->
  name: 'minify'

  transformBundle: (code) ->
    result = minify code, fromString: true

    # Strip sourcemaps comment and extra \n
    if result.map
        commentPos  = result.code.lastIndexOf '//#'
        result.code = result.code.slice(0, commentPos).trim()

    result
