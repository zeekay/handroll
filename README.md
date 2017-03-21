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
  entry: 'src/index.coffee'  # Path to entry module, required

  # Use `format` or `formats` to customize export format. Handroll defaults to
  # ES module format. Multiple formats may be specified using `formats`:
  #
  # formats: ['cjs', 'es']
  format:  'es'

  # Use `dest` to specify where a given format should be written. By default
  # Handroll will infer dest based on your package.json:
  #
  #   format -> default dest
  #   cjs    -> pkg.main
  #   es     -> pkg.module
  #   cli    -> pkg.bin
  #   web    -> pkg.name + '.js'
  dest: 'dist/lib.js'

  # Use `compilers` to Customize plugins automatically used per-filetype:
  #
  # compilers:
  #   coffee:
  #     verison: 1
  #
  # Or specify your own:
  #
  # compilers:
  #   js:   buble()
  #   less: less()
  compilers:
    coffee: coffe2()
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

  # Use `plugin` to override plugins Handroll should use. Other than compilers
  # (which are automatically detected based on filetypes used, most plugins will
  # be inferred based on your other options.
  #
  # plugins: [buble(), commonjs()]
  plugins:    null

  # Use `external` to configure which dependencies Rollup considers external. By
  # default Handroll will try to automatically infer external dependencies based
  # on your package.json. Use `external: false` or an explicit list will disable
  # this behavior.
  #
  # external: Object.keys pkg.dependencies
  external:   true

  basedir:    './'   # Customize basedir used for resolution
  commonjs:   false  # Enable importing from CommonJS modules
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
# Create new bundle
var bundle = await handroll.bundle entry: 'src/index.coffee'

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
