module Fastlane
  module Actions
    class StoreSizeXcarchiveCheckAction < Action
      # Apple sizes reference http://goo.gl/6A3nQK
      MAX_TEXT_6_LESS = 80_000_000
      MAX_SEGMENT_7_TO_8 = 60_000_000
      MAX_TEXT_9_PLUS = 500_000_000
      DEFAULT_MAX_WIFI_SIZE = 100_000_000

      def self.run(params)
        report = params[:report]

        errors = 0
        error = proc do |message|
          errors += 1
          UI.error(message)
        end

        unless report["min_os_version"].nil?
          major_version = report["min_os_version"][0]
          text_size = report["text_segments_size"]
          max_slice_size = report["text_max_slice_size"]
          error.call("__TEXT segments size #{text_size} greater than #{MAX_TEXT_6_LESS}") if major_version <= 6 && text_size > MAX_TEXT_6_LESS
          error.call("__TEXT #{max_slice_size} greater than #{MAX_SEGMENT_7_TO_8}") if major_version.between?(7, 8) && max_slice_size > MAX_SEGMENT_7_TO_8
          error.call("__TEXT segments size #{text_size} greater than #{MAX_TEXT_9_PLUS}") if major_version >= 9 && text_size > MAX_TEXT_9_PLUS
        end

        max_wifi_size = params[:max_wifi_size] || DEFAULT_MAX_WIFI_SIZE

        if max_wifi_size > 0 && !report["variants"].nil?
          report["variants"].each do |name, variant|
            next if variant["variantIds"].nil? && params[:ignore_universal]

            size = variant["sizeCompressedApp"]
            error.call("Variant #{name} size #{size} greater than #{max_wifi_size}") if size > max_wifi_size
          end
        end

        UI.test_failure!("Size check failed, #{errors} sizes exceeded the limits") if errors > 0

        UI.success("App size check suceeded")
      end

      def self.description
        "Checks if the size report fits the requirements"
      end

      def self.authors
        ["Marcelo Oliveira"]
      end

      def self.output
      end

      def self.return_value
      end

      def self.details
        "Checks estimated size for all non-universal variants and maximum executable sizes"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :report,
                                       description: 'Generated report. Optional if you use the `store_size_xcarchive` action',
                                       default_value: Actions.lane_context[SharedValues::SIZE_REPORT],
                                       type: Hash,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid report!'") if !Helper.test? && value["variants"].nil?
                                       end),
          FastlaneCore::ConfigItem.new(key: :ignore_universal,
                                       description: 'True to ignore universal variant',
                                       default_value: true,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :max_wifi_size,
                                       description: 'Max Wi-Fi download size, pass 0 to ignore',
                                       default_value: DEFAULT_MAX_WIFI_SIZE,
                                       type: Integer,
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
