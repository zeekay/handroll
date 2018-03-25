import fs   from 'fs'
import path from 'path'
import {detectFormats, formatOpts} from './formats'

# Helper to write bundle
export write = (bundle, opts) ->
  opts = Object.assign {}, opts
  # Don't pass our specialized options to rollup
  delete opts.executable
  delete opts.moduleName
  bundle.write formatOpts opts

# Helper to write multiple formats
export writeAll = (bundle, opts) ->
  ps = []

  for fmt in detectFormats opts
    ps.push write bundle, Object.assign {}, opts, format: fmt

  Promise.all ps
