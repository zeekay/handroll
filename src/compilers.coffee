# import buble  from 'rollup-plugin-buble'
import coffee2      from 'rollup-plugin-coffee2'
import typescript   from 'rollup-plugin-typescript'
import json         from 'rollup-plugin-json'
import pug          from 'rollup-plugin-pug'
import string       from 'rollup-plugin-string'
import stylup       from 'rollup-plugin-stylup'

import autoprefixer from 'autoprefixer'
import cssnano      from 'cssnano'
import lost         from 'lost'
import lostStylus   from 'lost-stylus'
import postcss      from 'poststylus'
import rupture      from 'rupture'

import log        from './log'
import {isPlugin} from './utils'

export default (opts) ->
  postPlugins = [
    lost()
    autoprefixer browsers: '> 1%'
  ]

  if opts.minify
    postPlugins.push cssnano()

  coffeeOpts        = Object.assign {}, opts.compilers?.coffee
  typescriptOpts    = Object.assign {}, opts.compilers?.typescript
  jsonOpts          = Object.assign {}, opts.compilers?.json
  pugOpts           = Object.assign {},
      compileDebug:           false
      inlineRuntimeFunctions: false
      pretty:                 if opts.minify then false else true
      sourceMap:              opts.sourcemap
      staticPattern:          /\S/
  , opts.compilers?.pug

  stylusOpts = Object.assign {},
    sourcemap: opts.sourcemap
    plugins: [
      lostStylus()
      rupture()
      postcss postPlugins
    ], opts.compilers?.stylus


  # Default compilers
  compilers =
    # js:     buble   jsOpts

    # Simple string compilers for .css and .html
    coffee:     coffee2    coffeeOpts
    css:        string     include: '**/*.css'
    html:       string     include: '**/*.html'
    json:       json       jsonOpts
    pug:        pug        pugOpts
    stylus:     stylup     stylusOpts
    typescript: typescript typescriptOpts

  compilers.css.name        = 'string-css'
  compilers.html.name       = 'string-html'
  compilers.typescript.name = 'typescript'

  # If passed a legitimate plugin, allow it to override default
  for k, v of opts.compilers
    compilers[k] = v if isPlugin v

  compilers
