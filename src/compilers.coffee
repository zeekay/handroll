# import buble  from 'rollup-plugin-buble'
import json    from 'rollup-plugin-json'
import pug     from 'rollup-plugin-pug'
import stylup  from 'rollup-plugin-stylup'
import coffee2 from 'rollup-plugin-coffee2'

import autoprefixer from 'autoprefixer'
import comments     from 'postcss-discard-comments'
import lost         from 'lost-stylus'
import postcss      from 'poststylus'
import rupture      from 'rupture'


export default (opts) ->
  return opts.compilers if opts.compilers

  # Default compilers
  compilers = {}

  compilers.coffee ?= coffee2()

  # compilers.js     ?= buble()
  compilers.json   ?= json()

  compilers.pug    ?= pug
    compileDebug:           true
    inlineRuntimeFunctions: false
    pretty:                 true
    sourceMap:              opts.sourceMap
    staticPattern:          /\S/

  compilers.stylus ?= stylup
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
    ]

  compilers
