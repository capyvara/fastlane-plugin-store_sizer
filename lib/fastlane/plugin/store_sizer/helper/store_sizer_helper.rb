module Fastlane
  module Helper
    class StoreSizerHelper
      # class methods that you define here become available in your action
      # as `Helper::StoreSizerHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the store_sizer plugin helper!")
      end
    end
  end
end
