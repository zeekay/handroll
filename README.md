# handroll
[![npm][npm-img]][npm-url]
[![build][build-img]][build-url]
<!-- [![coverage][coverage-img]][coverage-url] -->
[![dependencies][dependency-img]][dependency-url]
[![download][download-img]][download-url]
[![license][license-img][license-url]
[![chat][gitter-img]][gitter-url]

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
Handroll's JavaScript API provides an interface similar to Rollup, with the
`bundle` step being optional (and only useful if you want to cache the
intermediate bundle). In most cases you'll want to use `.write` or `.generate`
directly.

Rollup and plugins are automatically inferred and configured based on your
package.json and other specified options. Built-in support for many file-types
(CoffeeScript, Stylus, Pug, JSON, etc).

#### handroll.bundle (options) -> Promise
Create a new `Bundle` and cache result of `bundle.rollup`.

#### handroll.write  (options) -> Promise
Create new `Bundle` and immediately export in appropriate format(s).

#### bundle.write    (options) -> Promise
Write bundle in appropriate format(s).

#### bundle.generate (options) -> Promise
Generate output in appropriate format(s).

#### bundle.rollup   (options) -> Promise
Automatically infer compilers, plugins, formats and other relevant options and
Rollup bundle.

#### options
All Handroll operations can be passed the same set of options.

```coffee
bundle = await handroll.bundle
  entry: 'src/index.coffee'  # Path to entry module, required

  # Use `format` or `formats` to customize export format. Handroll defaults to
  # ES module format. Multiple formats may be specified using `formats`:
  #
  # formats: ['cjs', 'es']
  format: 'es'

  # Use `dest` to specify where a given format should be written. By default
  # Handroll will infer dest based on your package.json:
  #
  #   format -> default dest
  #   cjs    -> pkg.main
  #   es     -> pkg.module
  #   cli    -> pkg.bin
  #   web    -> pkg.name + '.js'
  dest: 'dist/lib.js'

  # Use `compilers` to customize plugins used per-filetype.
  #
  # compilers:
  #   coffee:
  #     verison: 1  # use CS 1.x instead of 2.x
  #
  # Or specify your own:
  #
  # compilers:
  #   js:   buble()
  #   less: less()
  compilers:
    coffee: coffee()
    json:   json()
    pug:    pug()
    styl:   stylus()

  # Use `legacy` to specificy non-module scripts and corresponding exports.
  # Non-module scripts installed with npm will be automatically resolved.
  #
  # legacy:
  #   './vendor/some.lib.js': 'someLib'
  #   prismjs: 'Prism'
  legacy: null

  # Use `plugins` to override plugins Handroll should use. By default Handroll
  # will try to automatically infer and configure the plugins you should use.
  #
  # plugins: [buble(), commonjs()]
  plugins: null

  # Use `external` to configure which dependencies Rollup considers external. By
  # default Handroll will try to automatically infer external dependencies based
  # on package.json. Normal dependencies are assumed to be external while
  # devDependencies are assumed to be fully subsumbed during the build step.
  # You can use `external: false` or an explicit list to disable this behavior.
  #
  # external: Object.keys pkg.dependencies
  external: true

  # Use `commonjs` to enable importing and customize CommonJS adaptor behavior.
  #
  # commonjs:
  #   namedExports:
  #     './module.js': ['foo', 'bar']
  commonjs: false

  basedir:    './'   # Customize basedir used for resolution
  details:    false  # Print extra details about bundle
  es3:        false  # Emit slightly more ES3-compliant output
  executable: false  # Include shebang and chmod+x output
  minify:     false  # Use uglify to minify bundle
  quiet:      false  # Suppress default output
  sourceMap:  true   # Collect and save source maps
  strip:      false  # Remove debugging and console log statements
```

### Examples
```coffee
import handroll from 'handroll'

# Create new bundle
bundle = await handroll.bundle
  entry: 'src/index.coffee'

# Write ES module for use by bundlers
await bundle.write format: 'es'

# Write CommonJS module for use by Node.js
await bundle.write format: 'cjs'

# Write IIFE bundle with all deps for web
await bundle.write format: 'web'

# Write executable with shebang using new entry module
await handroll.write
  entry:  'src/cli.coffee'
  format: 'cli'
```

[build-img]:      https://img.shields.io/travis/zeekay/handroll.svg
[build-url]:      https://travis-ci.org/zeekay/handroll
[chat-img]:       https://badges.gitter.im/join-chat.svg
[chat-url]:       https://gitter.im/zeekay/hi
[coverage-img]:   https://coveralls.io/repos/zeekay/handroll/badge.svg?branch=master&service=github
[coverage-url]:   https://coveralls.io/github/zeekay/handroll?branch=master
[dependency-img]: https://david-dm.org/zeekay/handroll.svg
[dependency-url]: https://david-dm.org/zeekay/handroll
[download-img]:   https://img.shields.io/npm/dm/handroll.svg
[download-url]:   http://badge.fury.io/js/handroll
[license-img]:    https://img.shields.io/npm/l/handroll.svg
[license-url]:    https://github.com/zeekay/handroll/blob/master/LICENSE
[npm-img]:        https://img.shields.io/npm/v/handroll.svg
[npm-url]:        https://www.npmjs.com/package/handroll
