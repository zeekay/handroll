# handroll [![NPM version][npm-img]][npm-url] [![Build Status][travis-img]][travis-url] [![Coverage Status][coveralls-img]][coveralls-url] [![Dependency Status][dependency-img]][dependency-url] [![Gitter chat][gitter-img]][gitter-url]
## Expertly rolled JavaScript
JavaScript API and CLI for for bundling opinionated JavaScript with
[Rollup](https://github.com/rollup/rollup). Tastes great with
[shortcake](https://github.com/zeekay/shortcake).

### Install
```bash
$ npm install handroll --save-dev
```

### CLI
```bash
$ handroll src/index.coffee --format web > index.js
```

### JavaScript API
Handroll's JavaScript API provides a similar interface to Rollup, with the
`bundle` step being optional (and only useful if you want to cache the
intermediate bundle). In most cases you'll want to juse use `.write` or
`.generate` directly.

Built-in support for many file-types (CoffeeScript, Stylus, Pug, JSON, etc).
Rollup.js options, plugins and write destination are automatically derived for
you from format option in most instances. Defaults can of course be easily
over-written.

```coffee
import handroll from 'handroll'

bundle = await handroll.bundle
  entry: 'src/index.coffee'  # Path to entry module

  # The following defaults may configured to customize logging and override the
  # behavior of handroll.

  # compilers:  null    Customize compilers used per-filetype
  # es3:        false   Emit slightly more ES3-compliant output
  # executable: false   Include shebang and chmod+x output
  # external:   false   Set package.json dependencies as external
  # sourceMap:  true    Collect and save source maps

  # quiet:      false   Suppress default output
  # details:    false   Print extra details about bundle

  # minify:     false   Use uglify to minify bundle
  # strip:      false   Remove debugging and console log statements

# Write ES module for use by bundlers (with external deps)
await bundle.write format: 'es'

# Write CommonJS module for use by Node.js (with external deps)
await bundle.write format: 'cjs'

# Write IIFE bundle with all deps for web
await bundle.write format: 'web'

# Write executable with shebang using new entry module
await handroll.write
  entry:  'src/cli.coffee'
  format: 'cli'
```

### Motivating example
```coffee
rollup        = require 'rollup'

autoTransform = require 'rollup-plugin-auto-transform'
builtins      = require 'rollup-plugin-node-builtins'
coffee        = require 'rollup-plugin-coffee-script'
commonjs      = require 'rollup-plugin-commonjs'
es3           = require 'rollup-plugin-es3'
filesize      = require 'rollup-plugin-filesize'
globals       = require 'rollup-plugin-node-globals'
json          = require 'rollup-plugin-json'
nodeResolve   = require 'rollup-plugin-node-resolve'
pug           = require 'rollup-plugin-pug'
strip         = require 'rollup-plugin-strip'
stylup        = require 'rollup-plugin-stylup'

postcss      = require 'poststylus'
autoprefixer = require 'autoprefixer'
comments     = require 'postcss-discard-comments'
lost         = require 'lost-stylus'

pkg = require './package.json'

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
  es3()
  strip()
  filesize()
]

bundle = await rollup.rollup
  entry:   'src/app.coffee'
  plugins: plugins

# App bundle for browser
await bundle.write
  dest:   'public/js/app.js'
  format: 'iife'
```

### License
[MIT](https://github.com/zeekay/handroll/blob/master/LICENSE)

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
