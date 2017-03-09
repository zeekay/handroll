import fs   from 'fs'
import path from 'path'

import {merge} from './utils'
import {detectFormat} from './format'


class Bundle
  constructor: (@bundle, @opts = {}) ->

  generate: merge (opts) ->
    @bundle.generate detectFormat opts

  write: merge (opts) ->
    # Default to app format
    opts.format ?= 'es'

    switch opts.format
      when 'app'
        @writeApp opts
      else
        @bundle.write detectFormat opts

  writeApp: merge (opts) ->
    opts = detectFormat opts

    fs.writeFileSync (path.join opts.basedir, 'index.html'), """
      <!DOCTYPE html>
      <html lang="en">
        <body>
          <script src="#{opts.dest}"></script>
        </body>
      </html>
      """

    @bundle.write opts

export default Bundle
