module Fastlane
  module Actions
    class StoreSizerAction < Action
      def self.run(params)
        UI.message("The store_sizer plugin is working!")
      end

      def self.description
        "Estimates download and install sizes for your app"
      end

      def self.authors
        ["Marcelo Oliveira"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Estimates download and install sizes for your app"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "STORE_SIZER_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
