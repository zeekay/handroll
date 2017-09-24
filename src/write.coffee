import fs   from 'fs'
import path from 'path'
import {detectFormats, formatOpts} from './formats'

# Helper to write bundle
export write = (bundle, opts) ->
  switch opts.format
    when 'app'
      bundle.write writeApp opts
    else
      bundle.write formatOpts opts

# Helper to write multiple formats
export writeAll = (bundle, opts) ->
  ps = []

  for fmt in detectFormats opts
    ps.push write bundle, Object.assign {}, opts, format: fmt

  Promise.all ps

export writeApp = (opts) ->
  opts = formatOpts opts
  fs.writeFileSync (path.join opts.basedir, 'index.html'), """
    <!DOCTYPE html>
    <html lang="en">
      <body>
        <script src="#{opts.output.file}"></script>
      </body>
    </html>
    """
  opts
