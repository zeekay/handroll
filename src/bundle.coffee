import fs   from 'mz/fs'
import path from 'path'

import {merge, moduleName} from './utils'

class Bundle
  constructor: (@bundle, @opts = {}) ->

  write: (opts = {}) ->
    opts = merge @opts, opts

    # Default to es module format
    opts.format ?= 'app'

    switch opts.format
      when 'app'
        @writeApp opts
      when 'esmodule', 'es'
        @writeModule opts
      when 'browser', 'iife'
        @writeBrowser opts
      when 'node',    'cjs'
        @writeCommonJS opts

  writeApp: merge (opts) ->
    dest = opts.dest ? opts.pkg.app ? opts.pkg.main

    stat = await fs.stat dest

    if stat.isDirectory()
      basedir = dest
      dest = path.join dest, 'app.js'
    else
      basedir = path.dirname dest

    await @bundle.write
      dest:      dest
      format:    'iife'
      sourceMap: opts.sourceMap

    await fs.writeFile (path.join basedir, 'index.html'), """
      <!DOCTYPE html>
      <html lang="en">
        <body>
          <script src="#{dest}"></script>
        </body>
      </html>
      """

  writeModule: merge (opts) ->
    @bundle.write
      dest:      opts.pkg.module
      format:    'es'
      sourceMap: opts.sourceMap

  writeBrowser: merge (opts) ->
    @bundle.write
      dest:       (moduleName opts.pkg.name) + '.js'
      format:     'iife'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

  writeCommonJS: merge (opts) ->
    @bundle.write
      dest:       opts.pkg.main
      format:     'cjs'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

export default Bundle
