export default (opts = {}) ->
  { minify } = require 'uglify-es'

  name: 'minify'
  transformBundle: (code, plugins, sourceMapChain, options) ->
    result = minify code,
      compress:    opts.compress   ? {}
      ie8:         opts.ie8        ? false
      keep_fnames: opts.keepFnames ? opts.keep_fnames ? false
      mangle:      opts.mangle     ? {}
      output:      opts.output     ? {}
      parse:       opts.parse      ? {}
      sourceMap:   opts.sourceMap  ? false
      toplevel:    opts.toplevel   ? false
      warnings:    opts.warnings   ? false
      wrap:        opts.wrap       ? false

    result
