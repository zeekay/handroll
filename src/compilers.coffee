# import buble  from 'rollup-plugin-buble'
import coffee2 from 'rollup-plugin-coffee2'
import json    from 'rollup-plugin-json'
import pug     from 'rollup-plugin-pug'
import stylup  from 'rollup-plugin-stylup'

import autoprefixer from 'autoprefixer'
import comments     from 'postcss-discard-comments'
import lost         from 'lost-stylus'
import postcss      from 'poststylus'
import rupture      from 'rupture'

import log        from './log'
import {isPlugin} from './utils'

export default (opts) ->
  coffeeOpts = Object.assign {}, opts.compilers?.coffee
  jsonOpts   = Object.assign {}, opts.compilers?.json
  pugOpts    = Object.assign {},
      compileDebug:           false
      inlineRuntimeFunctions: false
      pretty:                 true
      sourceMap:              opts.sourceMap
      staticPattern:          /\S/
  , opts.compilers?.pug

  stylusOpts = Object.assign {},
    sourceMap: opts.sourceMap
    plugins: [
      lost()
      rupture()
      postcss [
        'css-mqpacker'
        'lost'
        autoprefixer browsers: '> 1%'
        comments removeAll: true
      ]
    ], opts.compilers?.stylus

  # Default compilers
  compilers =
    coffee: coffee2 coffeeOpts
    # js:     buble   jsOpts
    json:   json    jsonOpts
    pug:    pug     pugOpts
    stylus: stylup  stylusOpts

  # If passed a legitimate plugin, all it to override the defaults
  for k,v of opts.compilers
    compilers[k] = v if isPlugin v

  compilers
