# handroll

[![npm][npm-img]][npm-url]
[![build][build-img]][build-url]
[![dependencies][dependencies-img]][dependencies-url]
[![downloads][downloads-img]][downloads-url]
[![license][license-img]][license-url]
[![chat][chat-img]][chat-url]

> Expertly rolled JavaScript

JavaScript API and CLI for for bundling opinionated JavaScript with
[Rollup](https://github.com/rollup/rollup). Provides a similar interface to
Rollup with many options and plugins automatically configured based on format
and `package.json`.

## Features
- Automatic external module detection
- Automatic node module resolution with improved resolution strategy
- Automatic transforms based on filetype with built-in support for many
  languages
- Automatic destination and format detection based on `package.json`:
    - `main` generates CommonJS module
    - `module` generates ES module bundle
    - `bin` generates executable
- Higher-level formats
    - `cli` bundles JS into an executable
    - `web` bundles JS for the browser
- Built-in minification support
- Built-in legacy module support
- Built-in CommonJS support
- Built-in statistics and details view
- Improved error handling and logging
- Sensible defaults

## Install
```bash
$ npm install handroll -g
```

## CLI
```bash
handroll

Usage:
  handroll <entry> [options]

Options:
  --commonjs     Enable CommonJS support
  --dest,   -o   Destination to write output
  --format, -f   Format to output
  --formats      Comma separated list of formats to output
  --es           ES module format
  --cjs          CommonJS module format
  --cli          Executable format
  --web          Web format
  --browser      Bundle for browser
  --module-name  Name to use for iife module
  --source-map   Enable source map support
  --minify       Enable minification

  --version      Print version information
  --help         Print this usage
```

## JavaScript API
Handroll's JavaScript API provides an interface similar to Rollup, with the
`bundle` step being optional (and only useful if you want to cache the
intermediate bundle). In most cases you'll want to use `.write` or `.generate`
directly.


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
All Handroll operations can be passed the similiar options.

```javascript
const bundle = await handroll.bundle({
  entry: 'src/index.js',  // Path to entry module, required

  // Use `format` or `formats` to customize export format. Handroll defaults to
  // ES module format. Multiple formats may be specified using `formats`:
  //
  // formats: ['cjs', 'es']
  format: 'es',

  // Use `dest` to specify where a given format should be written. By default
  // Handroll will infer dest based on your package.json:
  //
  //   format -> default dest
  //   cjs    -> pkg.main
  //   es     -> pkg.module
  //   cli    -> pkg.bin
  //   web    -> pkg.name + '.js'
  dest: 'dist/lib.js',

  // Use `compilers` to customize plugins used per-filetype.
  //
  // compilers: {
  //   coffee: {
  //     verison: 1  // use CS 1.x instead of 2.x
  //   }
  // }
  //
  // Or specify your own:
  //
  // compilers: {
  //   js:   buble()
  //   less: less()
  // }
  compilers: {
    coffee: coffee(),
    json:   json(),
    pug:    pug(),
    styl:   stylus(),
  },

  // Use `legacy` to specificy non-module scripts and corresponding exports.
  // Non-module scripts installed with npm will be automatically resolved.
  //
  // legacy: {
  //   './vendor/some.lib.js': 'someLib',
  //   prismjs: 'Prism'
  // }
  legacy: null,

  // Use `plugins` to override plugins Handroll should use. By default Handroll
  // will try to automatically infer and configure the plugins you should use.
  //
  // plugins: [buble(), commonjs()]
  plugins: null,

  // Use `external` to configure which dependencies Rollup considers external. By
  // default Handroll will try to automatically infer external dependencies based
  // on package.json. Normal dependencies are assumed to be external while
  // devDependencies are assumed to be fully subsumbed during the build step.
  // You can use `external: false` or an explicit list to disable this behavior.
  //
  // external: Object.keys pkg.dependencies
  external: true,

  // Use `commonjs` to enable importing and customize CommonJS adaptor behavior.
  //
  // commonjs:
  //   namedExports:
  //     './module.js': ['foo', 'bar']
  commonjs: false,

  basedir:    './',   // Customize basedir used for resolution
  details:    false,  // Print extra details about bundle
  es3:        false,  // Emit slightly more ES3-compliant output
  executable: false,  // Include shebang and chmod+x output
  minify:     false,  // Use uglify to minify bundle
  quiet:      false,  // Suppress default output
  sourceMap:  true ,  // Collect and save source maps
  strip:      false,  // Remove debugging and console log statements
})
```

## Examples
```javascript
import handroll from 'handroll'

// Create new bundle
const bundle = await handroll.bundle({
  entry: 'src/index.js'
})

// Write ES module (for use by bundlers)
await bundle.write({
  format: 'es'
  // dest: pkg.module
})

// Write CommonJS module (for use by Node.js)
await bundle.write({
  format: 'cjs'
  // dest: pkg.main
})

// Write ES module and CommonJS module
await bundle.write({formats: ['cjs', 'es']})

// If 'main' and 'module' are specified in your package.json, formats can be omitted
await bundle.write()

// Write bundle for web, using browser modules and ensuring no dependencies are excluded
await bundle.write({
  format: 'web',
  // external: false,
  // browser:  true,
  // dest:     pkg.name + '.js',
})

// Write executable with shebang using new entry module
await handroll.write({
  entry:  'src/cli.js',
  format: 'cli',
  // executable: true,
  // external:   true,
  // dest:       pkg.bin,
})

// Share options across multiple destinations
const bundle = new handroll.Bundle({
  entry:    'src/index.js',
  external: false
})
await Promise.all([
  bundle.write({format: 'es'}),
  bundle.write({format: 'cjs'}),
])
```

### Example `package.json`
```javascript
{
  "name":        "mylib",
  "main":        "lib/mylib.js",  // CommonJS dest
  "module":      "lib/mylib.mjs", // ES module dest
  "jsnext:main": "lib/mylib.mjs", // For compatibility with outdated bundlers

  // To ensure your generated files are packaged correctly:
  "files": [
    "lib/",
    "src/"
  ],
  "scripts": {
    "prepublishOnly": "handroll src/index.js --formats cjs,es"
  }
}
```

## License
[MIT][license-url]

[build-img]:        https://img.shields.io/travis/zeekay/handroll.svg
[build-url]:        https://travis-ci.org/zeekay/handroll
[chat-img]:         https://badges.gitter.im/join-chat.svg
[chat-url]:         https://gitter.im/zeekay/hi
[coverage-img]:     https://coveralls.io/repos/zeekay/handroll/badge.svg?branch=master&service=github
[coverage-url]:     https://coveralls.io/github/zeekay/handroll?branch=master
[dependencies-img]: https://david-dm.org/zeekay/handroll.svg
[dependencies-url]: https://david-dm.org/zeekay/handroll
[downloads-img]:    https://img.shields.io/npm/dm/handroll.svg
[downloads-url]:    http://badge.fury.io/js/handroll
[license-img]:      https://img.shields.io/npm/l/handroll.svg
[license-url]:      https://github.com/zeekay/handroll/blob/master/LICENSE
[npm-img]:          https://img.shields.io/npm/v/handroll.svg
[npm-url]:          https://www.npmjs.com/package/handroll
