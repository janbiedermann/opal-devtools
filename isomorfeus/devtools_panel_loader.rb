require 'opal'
require 'opal-activesupport'
require 'opal-parser'
require 'opal/compiler'
require 'opal-autoloader'
require 'browser/support'
require 'isomorfeus-redux'
require 'isomorfeus-react'
require 'isomorfeus-react-material-ui'

require_tree 'components'

Isomorfeus.start_app!
