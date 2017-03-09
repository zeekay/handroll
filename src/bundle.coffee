import fs    from 'fs'
import path  from 'path'

import chalk from 'chalk'
import rollup from 'rollup'

import plugins from './plugins'
import {merge} from './utils'
import {detectFormat} from './format'


cache = null

getExternal = (pkg, dev = false) ->
  deps    = Object.keys pkg.dependencies    ? {}
  devDeps = Object.keys pkg.devDependencies ? {}

  if dev
    deps.concat devDeps
  else
    deps

writeApp = (opts) ->
  opts = detectFormat opts
  fs.writeFileSync (path.join opts.basedir, 'index.html'), """
    <!DOCTYPE html>
    <html lang="en">
      <body>
        <script src="#{opts.dest}"></script>
      </body>
    </html>
    """
  opts


class Bundle
  constructor: (@opts = {}) ->
    return new Bundle @opts unless @ instanceof Bundle

  rollup: (opts) ->
    if opts.external == true
      opts.external = getExternal opts.pkg
      unless opts.quiet
        console.log 'external:'
        for dep in opts.external
          console.log " - #{dep}"

    new Promise (resolve, reject) ->
      rollup.rollup
        acorn:      opts.acorn
        cache:      opts.cache ? cache
        entry:      opts.entry
        external:   opts.external
        plugins:    plugins opts
        sourceMap:  opts.sourceMap
      .then (bundle) =>
        resolve bundle
        unless opts.quiet
          console.log chalk.white.bold opts.entry
      .catch (err) ->
        if err.plugin? and err.id?
          console.error "Plugin '#{err.plugin}' failed on module #{err.id}"
        else if err.id?
          console.error "Failed to parse module #{err.id}"
        else
          console.error err.stack
        reject err

  generate: merge (opts) ->
    new Promise (resolve, reject) =>
      @rollup opts
        .then (bundle) ->
          resolve bundle.generate detectFormat opts
        .catch (err) ->
          reject err

  write: merge (opts) ->
    new Promise (resolve, reject) =>
      @rollup opts
        .then (bundle) =>
          switch opts.format
            when 'app'
              resolve bundle.write writeApp opts
            else
              resolve bundle.write detectFormat opts
        .catch (err) ->
          reject err

export default Bundle
