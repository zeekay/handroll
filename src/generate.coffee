import {detectFormat} from './formats'

export generate = (bundle, opts) ->
  bundle.generate detectFormat opts


