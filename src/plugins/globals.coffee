import globals from 'rollup-plugin-node-globals'

export default (opts = {}) ->
  plugin = globals opts
  plugin.name = 'node-globals'
  plugin
