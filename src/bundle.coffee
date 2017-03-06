import path from 'path'

import {merge, moduleName} from './utils'
import fs from './fs'


class Bundle
  constructor: (@bundle, @opts = {}) ->

  write: merge (opts) ->
    # Default to app format
    opts.format ?= 'es'

    switch opts.format
      when 'app'
        @writeApp opts
      when 'lib',  'library'
        @writeLib opts
      when 'es',   'esmodule'
        @writeMod opts
      when 'iife', 'web'
        @writeWeb opts
      when 'cjs',  'node'
        @writeCjs opts
      else
        throw new Error 'Unsupported export format'

  writeApp: merge (opts) ->
    dest = opts.dest ? opts.pkg.app ? opts.pkg.main

    stat = await fs.stat dest

    if stat.isDirectory()
      basedir = dest
      dest    = path.join dest, 'app.js'
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

  writeMod: merge (opts) ->
    dest = opts.dest ? opts.pkg.module ? opts.pkg['js:next'] ? 'index.mjs'
    @bundle.write
      dest:      opts.pkg.module
      format:    'es'
      sourceMap: opts.sourceMap

  writeCjs: merge (opts) ->
    dest = opts.dest ? opts.pkg.main ? 'index.js'
    @bundle.write
      dest:       opts.pkg.main
      format:     'cjs'
      sourceMap:  opts.sourceMap

  writeWeb: merge (opts) ->
    dest = opts.dest ? ((moduleName opts.pkg.name) + '.js').toLowerCase()
    @bundle.write
      dest:       dest
      format:     'iife'
      moduleName: moduleName opts.pkg.name
      sourceMap:  opts.sourceMap

  writeLib: merge (opts) ->
    Promise.all [
      @writeCjs()
      @writeMod()
    ]

export default Bundle
