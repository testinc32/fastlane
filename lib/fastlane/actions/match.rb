module Fastlane
  module Actions
    class MatchAction < Action
      def self.run(params)
        require 'match'

        params.load_configuration_file("Fixfile")
        Match::Runner.new.run(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "TODO"
      end

      def self.details
        "More details https://github.com/fastlane/match"
      end

      def self.available_options
        require 'match'
        Match::Options.available_options
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
