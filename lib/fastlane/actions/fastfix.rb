module Fastlane
  module Actions
    class FastfixAction < Action
      def self.run(params)
        require 'fastfix'

        params.load_configuration_file("Fixfile")
        Fastfix::Runner.new.run(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "TODO"
      end

      def self.details
        "More details https://github.com/fastlane/fastfix"
      end

      def self.available_options
        require 'fastfix'
        Fastfix::Options.available_options
      end

      def self.output
        []
      end

      def self.return_value
        
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
