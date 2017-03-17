import {enableAsync} from './utils'
import log from './log'

enableAsync()

import Bundle   from './bundle'
import Handroll from './handroll'

handroll = new Handroll()
handroll.Bundle   = Bundle
handroll.Handroll = Handroll
handroll.verbose  = log.verbose

export default handroll
