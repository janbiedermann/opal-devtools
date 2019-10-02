require 'opal'
require 'opal-parser'
require 'opal/compiler'
require 'opal-autoloader'
require 'opal-browser'
require 'isomorfeus-redux'
require 'isomorfeus-react'
require 'isomorfeus-react-material-ui'

require_tree 'components'

Isomorfeus.start_app!
