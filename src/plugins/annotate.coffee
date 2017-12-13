import path  from 'path'
import magic from 'magic-string'


export default (opts = {}) ->
  name: 'annotate'
  transform: (source, id) ->
    filename = path.relative process.cwd(), id
    ms = (new magic source).prepend "// #{filename}\n"
    result =
      code: ms.toString()

    if opts.sourcemap
      result.map = ms.generateMap hires: true
    result
