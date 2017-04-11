import log       from './log'
import {isArray} from './utils'

# Get external packages from package.json
export getDeps = (pkg, dev = false) ->
  deps     = Object.keys pkg.dependencies     ? {}
  devDeps  = Object.keys pkg.devDependencies  ? {}
  peerDeps = Object.keys pkg.peerDependencies ? {}

  # Should always include peer dependencies, these are not even part of the
  # package being bundled.
  deps = deps.concat peerDeps

  if dev
    deps.concat devDeps
  else
    deps

# Convert external opt into detected externals based on option selected
detectExternal = (external, pkg) ->
  if external == true or !external?
    external = getDeps pkg
  if external == 'dev'
    external = getDeps pkg, true
  if external == false
    external = []
  external

# Remove included deps from detected externals
removeIncluded = (external, include = []) ->
  for dep in include by -1
    console.log dep
    if ~external.indexOf dep
      log " + #{dep} included"
      external.splice i, 1
  external

# Log detected external deps
logExternal = (external) ->
  if external.length
    log 'external:'
    for dep in external
      log " - #{dep}"
  else
    log 'no externals'

# autoExternal uses your package.json to guess which dependencies should be
# considered external. By default only dependencies in pkg.dependencies will be
# considered external as pkg.devDependencies are generally only required as
# part of a build or development process. If this isn't what you want you
# should manually specify external dependencies instead.
export autoExternal = ({external, include, pkg}) ->
  return external if isArray external

  console.log 'detected externals'
  externals = detectExternal external, pkg
  removeIncluded externals, include
  logExternal externals
  externals
