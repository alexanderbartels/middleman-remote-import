# Require core library
require 'middleman-core'

# Extension namespace
# Extension namespace
module Middleman
  module Import
    @options

    class << self
      attr_reader :options

      attr_writer :options
    end

    class Extension < ::Middleman::Extension
      option :path, nil
      option :pluginCategory, 'released'
      option :failFast, false, 'helpful for development or to test import on PullRequests. If false errors on plugin import are ignored.'

      def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        yield options if block_given?

        # Require libraries only when activated
        # require 'necessary/library'

        # set up your extension
        # puts options.my_option
      end

      def after_configuration
        ::Middleman::Import.options = options
      end

      # A Sitemap Manipulator
      # def manipulate_resource_list(resources)
      # end

      # helpers do
      #   def a_helper
      #   end
      # end
    end
  end
end
