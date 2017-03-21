import {gray, white} from './colors'

verbose = true

log = ->
  if verbose
    console.log.apply console, arguments

log.error = ->
  if verbose
    console.error.apply console, arguments

log.verbose = (bool) ->
  verbose = bool

log.gray = (message) ->
  log gray message

log.white = (message) ->
  log white message

log.white.bold = (message) ->
  log white.bold message

log.white.dim = (message) ->
  log white.dim message

export default log
