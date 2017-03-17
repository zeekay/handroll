import {isArray} from 'es-is'

import log from './log'


# Get external packages from package.json
export getExternal = (pkg, dev = false) ->
  deps    = Object.keys pkg.dependencies    ? {}
  devDeps = Object.keys pkg.devDependencies ? {}

  if dev
    deps.concat devDeps
  else
    deps

# autoExternal uses your package.json to guess which dependencies should be
# considered external. By default only dependencies in pkg.dependencies will be
# considered external as pkg.devDependencies are generally only required as
# part of a build or development process. If this isn't what you want you
# should manually specify external dependencies instead.
export autoExternal = ({external, pkg}) ->
  return external if isArray external

  if external == true or !external?
    external = getExternal pkg
  else if external == false
    external = []
  else if external == 'dev'
    external = getExternal pkg, true

  if external.length
    log 'external:'
    for dep in external
      log " - #{dep}"

  external
