import fs             from 'fs'
import path           from 'path'
import builtins       from 'builtin-modules'
import browserResolve from 'browser-resolve'
import nodeResolve    from 'resolve'

COMMONJS_BROWSER_EMPTY = nodeResolve.sync 'browser-resolve/empty.js', __dirname
ES6_BROWSER_EMPTY      = path.resolve __dirname, '../src/plugins/empty.js'


export default (opts = {}) ->
  extensions     = opts.extensions
  preferBuiltins = opts.preferBuilts ? true
  skip           = opts.skip         ? []

  resolveId = if opts.browser then browserResolve else nodeResolve

  seen = {}

  name: 'node-resolve'
  resolveId: (importee, importer) ->
    return null if /\0/.test importee # Ignore IDs with null character, these belong to other plugins
    return null if !importer          # Disregard entry module

    parts = importee.split /[\/\\]/
    id    = parts.shift()

    basedir = opts.basedir ? path.dirname importer

    if id[0] == '@' && parts.length
      # scoped packages
      id += "/#{parts.shift()}"
    else if id[0] == '.'
      # An import relative to the parent dir of the importer, force basedir to
      # match importer
      basedir  = path.dirname importer
      id       = path.resolve importer, '..', importee
      relative = true

    return if ~skip.indexOf id

    new Promise (resolve, reject) ->
      opts =
        basedir:    basedir
        extensions: extensions
        packageFilter: (pkg) ->
          # Try in order: 'module', 'jsnext:main' and 'main' fields.
          if pkg.module
            pkg.main = pkg.module
          else if pkg['jsnext:main']
            pkg.main = pkg['jsnext:main']

          unless pkg.main or relative
            reject Error "Package #{importee} (imported by #{importer}) does not have a main, module or jsnext:main field"
            console.log pkg
          pkg

      resolveId importee, opts, (err, resolved) ->
        return reject Error "Could not resolve '#{importee}' from #{path.normalize importer}" if err?

        # Empty modules?
        if resolved == COMMONJS_BROWSER_EMPTY
          return resolve ES6_BROWSER_EMPTY

        # Built-in module previously resolved?
        if ~builtins.indexOf resolved
          return resolve null

        # Prefer built-ins
        if preferBuiltins and ~builtins.indexOf importee
          unless opts.quiet
            console.log "preferring built-in module '#{importee}' over local alternative at '#{resolved}'"
          return resolve null

        # Resolve symlinks
        fs.exists resolved, (exists) ->
          unless exists
            unless opts.quiet
              console.log "resolved #{resolved}, but it doesn't exist"
            return resolve null

          fs.realpath resolved, (err, resolved) ->
            return reject err if err?
            resolve resolved
