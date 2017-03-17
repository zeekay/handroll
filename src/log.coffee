import {white} from './colors'

verbose = true

log = ->
  if verbose
    console.log.apply console, arguments

log.error = ->
  if verbose
    console.error.apply console, arguments

log.verbose = (bool) ->
  verbose = bool

log.white = (message) ->
  log white message

log.white.bold = (message) ->
  log white.bold message

export default log
