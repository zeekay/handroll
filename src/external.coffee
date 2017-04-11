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
removeIncluded = (externals, include = []) ->
  removed = []
  for dep in include by -1
    if ~externals.indexOf dep
      externals.splice i, 1
      removed.push dep
  removed

# Log detected external deps
logExternals = (externals) ->
  if externals.length
    log 'external:'
    for dep in externals
      log " - #{dep}"
  else
    log 'no externals'
  return

# Log detected external deps
logIncluded = (included) ->
  if included.length
    log 'included:'
    for dep in included
      log " + #{dep}"
  return

# autoExternal uses your package.json to guess which dependencies should be
# considered external. By default only dependencies in pkg.dependencies will be
# considered external as pkg.devDependencies are generally only required as
# part of a build or development process. If this isn't what you want you
# should manually specify external dependencies instead.
export autoExternal = ({external, include, pkg}) ->
  return external if isArray external

  externals = detectExternal external,  pkg
  included  = removeIncluded externals, include

  logExternals externals
  logIncluded  included

  externals
