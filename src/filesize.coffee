import chalk    from 'chalk'
import fileSize from 'filesize'
import gzip     from 'gzip-size'


render = (filename, size, gzipSize) ->
  gb = chalk.green.bold
  wb = chalk.white.bold
  """
  ⇢ #{wb filename}\t#{gb size} (#{gb gzipSize} compressed)
  """

export default filesize = (opts = {}) ->
  opts.format ?= {}
  ongenerate: (bundle, result) ->
    size = fileSize Buffer.byteLength result.code, opts.format
    gzipSize = fileSize gzip.sync(result.code), opts.format
    console.log ' ' + render bundle.dest, size, gzipSize
