import log       from './log'
import {version} from '../package.json'

# Create a merged copy of a set of objects
export merge = (fn) ->
  (opts) ->
    opts = (Object.assign {}, @opts, opts)
    log.verbose !opts.quiet if opts.quiet?
    opts.input ?= opts.entry # TODO: Get rid of hack
    fn.call @, opts

# Try to guess moduleName (used in export for browser bundles)
export moduleName = (name) ->
  return '' unless name.trim()
  first = name.charAt(0).toUpperCase()
  name  = name.replace /\.js$|\.coffee$|-js$/, ''
  name  = name.replace /-([a-z])/g, (g) -> g[1].toUpperCase()
  first + name.slice 1

export isPlugin = do ->
  keys = new Set [
    'name'
    'options'
    'load'
    'resolveId'
    'transform'
    'transformBundle'
    'ongenerate'
    'onwrite'
    'intro'
    'outro'
    'banner'
    'footer'
  ]

  (obj) ->
    for own k of obj
      if keys.has k
        return true
    false

export banner = ->
  unless banner.seen?
    log.white.dim "handroll v#{version} 🍣"
    banner.seen = true

export isArray  = (v) -> Array.isArray v
export isString = (v) -> typeof v == 'string' or v instanceof String
