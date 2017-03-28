import Bundle   from './bundle'
import Handroll from './handroll'
import log      from './log'
import pkg      from '../package.json'

handroll = new Handroll()
handroll.Bundle   = Bundle
handroll.Handroll = Handroll
handroll.verbose  = log.verbose
handroll.version  = pkg.version

export default handroll
