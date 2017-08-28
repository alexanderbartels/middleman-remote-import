require "middleman-core"

require 'middleman-remote-import/commands'

Middleman::Extensions.register :remote_import do
  require "middleman-remote-import/extension"
  ::Middleman::Import::Extension
end
