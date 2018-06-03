import builtins from '@zeekay/rollup-plugin-node-builtins'

export default (opts = {}) ->
  plugin = builtins opts
  plugin.name = 'node-builtins'
  plugin
