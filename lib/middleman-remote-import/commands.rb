require "middleman-core"
require 'middleman-core/cli'

require 'open-uri'

module Middleman
  module Cli
    # This class provides a "deploy" command for the middleman CLI.
    class Import < Thor::Group
      include Thor::Actions

       check_unknown_options!

      # Template files are relative to this file
      # @return [String]
      def self.source_root
        File.dirname( __FILE__ )
      end

       namespace :import

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def import
        opts = import_options

        puts "Starting import..."

        # spin up Middleman application
        app = ::Middleman::Application.new do
          config[ :mode ]              = :config
          config[ :disable_sitemap ]   = true
          config[ :watcher_disable ]   = true
          config[ :exit_before_ready ] = true
        end


        # iterate over all configured plugins
        app.data.plugins[opts.pluginCategory].each { | v | 
          name = v["name"] # plugin name. e.g. jet-js-plugin-sticky
          slug = v["slug"] || name # url slug. (/plugins/<slug>) No whitespaces! e.g. slug="sticky" resulting in an url like /plugins/sticky
          repository = v["repository"] || name # name of the repository. if not defined the plugin name is used
          displayName = v["displayName"] || name # plugin name to display in Headlines etc. Can contain whitespaces
          authorName  = v["authorName"] || "" # Author name, can be empty
          authorProfile = v["authorProfile"] # "Github username. Used to build the URLs to fetch files"
          branch = v["branch"] || "master" # which branch to use. default to master
          readmeFileName = v["readme"] || "README.md" # readme file name.

          # TODO: raise errors if not all needed properties are defined

          # make sure the slug is a valid slug (https://stackoverflow.com/questions/4308377/ruby-post-title-to-slug)
          slug = slug.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

          readmePath = File.join(app.source_dir, 'plugins', "#{slug}.html.md")
          puts "Import plugin: #{name}"

          begin
            # request readme
            requestURL = "https://github.com/#{authorProfile}/#{repository}/raw/#{branch}/#{readmeFileName}"
            readmeContent = open(requestURL).read
            # TODO handle 404 or other Errors. Ignore Plugin and continue

            # Safety first => remove YAML frontmatter
            readmeContent = readmeContent.gsub(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m,'')
            
            # add custom frontmatter from data 
            frontmatter = "---\n" + 
              (name.empty? ? "" : "name: \"#{name}\"\n") + 
              (slug.empty? ? "" : "slug: \"#{slug}\"\n") + 
              (repository.empty? ? "" : "repository: \"#{repository}\"\n") + 
              (displayName.empty? ? "" : "displayName: \"#{displayName}\"\n") + 
              (authorName.empty? ? "" : "authorName: \"#{authorName}\"\n") + 
              (authorProfile.empty? ? "" : "authorProfile: \"#{authorProfile}\"\n") + 
              "---\n\n"
              

            readmeContent = frontmatter + readmeContent

            File.write(readmePath, readmeContent)
            puts "Plugin Import: success (#{readmePath})"
          rescue Exception => e  
            puts "Plugin Import: failed", e
            # only fail if pts.failFast is set to true
            raise e if opts.failFast
          end
        }
      end

      protected

      def import_options
        options = nil

        begin
          options = ::Middleman::Import.options
        rescue NoMethodError
          print_usage_and_die 'You need to activate the remote_import extension in config.rb.'
        end

        unless options.path
          print_usage_and_die 'The remote_import extension requires you to set a path.'
        end

        options
      end

      def print_usage_and_die
        fail StandardError, "ERROR: TODO - print readme"
      end
    end

    # Add to CLI
    Base.register(Middleman::Cli::Import, 'import', 'import [options]', 'Remote Import um via http Seiten zu laden.')
  end
end
