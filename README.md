# handroll [![NPM version][npm-img]][npm-url] [![Build Status][travis-img]][travis-url] [![Coverage Status][coveralls-img]][coveralls-url] [![Dependency Status][dependency-img]][dependency-url] [![Gitter chat][gitter-img]][gitter-url]
A delicious hand roll of [Rollup](rollup) plugins.

### Motivating example
```coffee

coffee      = require 'rollup-plugin-coffee-script'
commonjs    = require 'rollup-plugin-commonjs'
nodeResolve = require 'rollup-plugin-node-resolve'
rollup      = require 'rollup'

plugins = [
  coffee()
  nodeResolve
    browser: true
    extensions: ['.js', '.coffee']
    module:  true
  commonjs
    extensions: ['.js', '.coffee']
    sourceMap: true
]

# Browser (single file)
bundle = await rollup.rollup
  entry:   'src/index.coffee'
  plugins:  plugins

await bundle.write
  format:     'iife'
  dest:       pkg.name + '.js'
  moduleName: pkg.name.charAt(0).toUpperCase() + pkg.name.slice 1

# CommonJS && ES Module
bundle = await rollup.rollup
  entry:    'src/index.coffee'
  external: Object.keys pkg.dependencies
  plugins:  plugins

bundle.write
  format:     'cjs'
  moduleName: pkg.name
  dest:       pkg.main
  sourceMap:  'inline'

bundle.write
  format:    'es'
  dest:      pkg.module
  sourceMap: 'inline'
```

## Install
```bash
$ npm install handroll --save-dev
```

## Usage
```coffee
handroll = require 'handroll'

bundle = await handroll.bundle
  entry: src/index.coffee

Promise.all [
  bundle.writeBrowser()
  bundle.writeCommonJS()
  bundle.write()
]
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
