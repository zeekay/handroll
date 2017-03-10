import fs from 'fs'
import {dirname, resolve, normalize} from 'path'

import nodeResolve    from 'resolve'
import browserResolve from 'browser-resolve'
import builtins       from 'builtin-modules'

COMMONJS_BROWSER_EMPTY = nodeResolve.sync 'browser-resolve/empty.js', __dirname
ES6_BROWSER_EMPTY      = resolve __dirname, '../src/plugins/empty.js'
CONSOLE_WARN           = (args...) -> console.warn args...


export default (options = {}) ->
  skip      = options.skip   ? []
  useJsnext = options.jsnext == true
  useModule = options.module != false
  useMain   = options.main   != false

  isPreferBuiltinsSet = options.preferBuiltins == true or options.preferBuiltins == false
  preferBuiltins      = if isPreferBuiltinsSet then options.preferBuiltins else true

  onwarn    = options.onwarn or CONSOLE_WARN
  resolveId = if options.browser then browserResolve else nodeResolve

  name: 'node-resolve'
  resolveId: (importee, importer) ->
    return null if /\0/.test importee # Ignore IDs with null character, these belong to other plugins
    return null if !importer          # Disregard entry module

    parts = importee.split /[\/\\]/
    id    = parts.shift()

    if id[0] == '@' && parts.length
      # scoped packages
      id += "/#{parts.shift()}"
    else if id[0] == '.'
      # an import relative to the parent dir of the importer
      id = resolve importer, '..', importee

    return if skip != true and ~skip.indexOf id

    new Promise (accept, reject) ->
      resolveId importee,
        basedir: dirname importer
        packageFilter: (pkg) ->
          if !useJsnext and !useMain and !useModule
            if skip == true
              accept false
            else
              reject Error "To import from a package in node_modules (#{importee}), either options.jsnext, options.module or options.main must be true"
          else if useModule && pkg['module']
            pkg['main'] = pkg['module']
          else if useJsnext && pkg['jsnext:main']
            pkg['main'] = pkg['jsnext:main']
          else if (useJsnext || useModule) && !useMain
            if skip == true
              accept false
            else
              reject Error "Package #{importee} (imported by #{importer}) does not have a module or jsnext:main field. You should either allow legacy modules with options.main, or skip it with options.skip = ['#{importee}'])"
          pkg
        extensions: options.extensions
      , (err, resolved) ->
        if resolved and fs.existsSync resolved
          resolved = fs.realpathSync resolved

        if err
          if skip == true
            accept false
          else
            reject Error "Could not resolve '#{importee}' from #{normalize importer}"
        else
          if resolved == COMMONJS_BROWSER_EMPTY
            accept ES6_BROWSER_EMPTY
          else if ~builtins.indexOf resolved
            accept null
          else if  ~builtins.indexOf importee && preferBuiltins
            if !isPreferBuiltinsSet
                onwarn """"
                  preferring built-in module '#{importee}' over local alternative
                  at '#{resolved}', pass 'preferBuiltins: false' to disable this
                  behavior or 'preferBuiltins: true' to disable this warning
                  """
            accept null
          else
            accept resolved
