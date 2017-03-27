import log           from './log'
import {enableAsync} from './utils'
import pkg           from '../package.json'

enableAsync()

import Bundle   from './bundle'
import Handroll from './handroll'

handroll = new Handroll()
handroll.Bundle   = Bundle
handroll.Handroll = Handroll
handroll.verbose  = log.verbose
handroll.version  = pkg.version

export default handroll
