# handroll [![NPM version][npm-img]][npm-url] [![Build Status][travis-img]][travis-url] [![Coverage Status][coveralls-img]][coveralls-url] [![Dependency Status][dependency-img]][dependency-url] [![Gitter chat][gitter-img]][gitter-url]
#### Expertly rolled JavaScript
JavaScript API and CLI for for bundling opinionated JavaScript with Rollup.js

### Motivating example
```coffee
autoTransform = require 'rollup-plugin-auto-transform'
builtins      = require 'rollup-plugin-node-builtins'
coffee        = require 'rollup-plugin-coffee-script'
commonjs      = require 'rollup-plugin-commonjs'
filesize      = require 'rollup-plugin-filesize'
globals       = require 'rollup-plugin-node-globals'
json          = require 'rollup-plugin-json'
nodeResolve   = require 'rollup-plugin-node-resolve'
pug           = require 'rollup-plugin-pug'
rollup        = require 'rollup'
stylup        = require 'rollup-plugin-stylup'

postcss      = require 'poststylus'
autoprefixer = require 'autoprefixer'
comments     = require 'postcss-discard-comments'
lost         = require 'lost-stylus'

pkg         = require './package.json'

plugins = [
  autoTransform()
  globals()
  builtins()
  coffee()
  pug
    pretty:                 true
    compileDebug:           true
    sourceMap:              false
    inlineRuntimeFunctions: false
    staticPattern:          /\S/
  stylup
    sourceMap: false
    plugins: [
      lost()
      postcss [
        autoprefixer browsers: '> 1%'
        'lost'
        'css-mqpacker'
        comments removeAll: true
      ]
    ]
  json()
  nodeResolve
    browser: true
    extensions: ['.js', '.coffee', '.pug', '.styl']
    module: true
    jsnext: true
  commonjs
    extensions: ['.js', '.coffee']
    sourceMap: false
  filesize()
]

bundle = await rollup.rollup
  entry:    'src/app.coffee'
  plugins:  plugins

# App bundle for browser
await bundle.write
  dest:      'public/js/app.js'
  format:    'iife'
```

..and that's with all the necessary scaffolding omitted.

## Install
```bash
$ npm install handroll --save-dev
```

## Usage
```coffee
handroll = require 'handroll'

await handroll.write
  entry: 'src/index.coffee'
  dest:  'public'
```



[travis-img]:     https://img.shields.io/travis/zeekay/handroll.svg
[travis-url]:     https://travis-ci.org/zeekay/handroll
[coveralls-img]:  https://coveralls.io/repos/zeekay/handroll/badge.svg?branch=master&service=github
[coveralls-url]:  https://coveralls.io/github/zeekay/handroll?branch=master
[dependency-url]: https://david-dm.org/zeekay/handroll
[dependency-img]: https://david-dm.org/zeekay/handroll.svg
[npm-img]:        https://img.shields.io/npm/v/handroll.svg
[npm-url]:        https://www.npmjs.com/package/handroll
[gitter-img]:     https://badges.gitter.im/join-chat.svg
[gitter-url]:     https://gitter.im/zeekay/hi

<!-- not used -->
[downloads-img]:     https://img.shields.io/npm/dm/handroll.svg
[downloads-url]:     http://badge.fury.io/js/handroll
[devdependency-img]: https://david-dm.org/zeekay/handroll/dev-status.svg
[devdependency-url]: https://david-dm.org/zeekay/handroll#info=devDependencies
