import chalk    from 'chalk'
import fileSize from 'filesize'
import gzip     from 'gzip-size'


render = (filename, size, gzipSize) ->
  gb = chalk.green.bold
  wb = chalk.white.bold
  " ⇢ #{wb filename}\t#{gb size} (#{gb gzipSize} compressed)"

export default (opts = {}) ->
  opts.format ?= {}

  name: 'filesize'
  ongenerate: (bundle, result) ->
    size = fileSize Buffer.byteLength result.code, opts.format
    gzipSize = fileSize gzip.sync(result.code), opts.format
    console.log render bundle.file, size, gzipSize
