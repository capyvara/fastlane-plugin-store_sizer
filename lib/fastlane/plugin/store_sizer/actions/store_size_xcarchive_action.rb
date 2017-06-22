module Fastlane
  module Actions
    class StoreSizeXcarchiveAction < Action
      def self.run(params)
        require 'plist'

        unless Fastlane::Helper.test?
          UI.user_error!("xcodebuild not installed") if `which xcodebuild`.length == 0
        end

        archive_path = params[:archive_path]
        app_path = Dir.glob(File.join(archive_path, "Products", "Applications", "*.app")).first()
        binary_name = File.basename(app_path, ".app")
        binary_path = File.join(app_path, binary_name)
        extra_file_path = File.join(app_path, "extradata_simulated")
        result = {}

        Dir.mktmpdir do |tmp_path|
          binary_backup_path = File.join(tmp_path, binary_name)
          export_path = File.join(tmp_path, "Export")
          begin
            FileUtils.mv(binary_path, binary_backup_path)
            FileUtils.cp(binary_backup_path, binary_path)
            Helper::StoreSizerHelper.write_random_encryption_segments(binary_path)
            Helper::StoreSizerHelper.write_random_file(extra_file_path, 2 * 1000 * 1000)

            export_options = {}
            export_options[:method] = 'ad-hoc'
            export_options[:thinning] = '<thin-for-all-variants>'
            export_options_plist_path = File.join(tmp_path, "ExportOptions.plist")
            File.write(export_options_plist_path, Plist::Emit.dump(export_options, false))

            UI.message("Exporting all variants of #{archive_path} for estimation...")
            Helper::StoreSizerHelper.xcode_export_package(archive_path, export_options_plist_path, export_path)

            UI.verbose(File.read(File.join(export_path, "App Thinning Size Report.txt")))

            result = Plist.parse_xml(File.join(export_path, "app-thinning.plist"))
          ensure
            FileUtils.rm(binary_path)
            FileUtils.mv(binary_backup_path, binary_path)
            FileUtils.rm(extra_file_path)
          end
        end

        result
      end

      def self.description
        "Estimates download and install sizes for your app"
      end

      def self.authors
        ["Marcelo Oliveira"]
      end

      def self.output
      end

      def self.return_value
        "Hash containing App Thinning report"
      end

      def self.details
        "Compute estimated size of the .ipa after encryption and App Thinning for all variants"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                       description: 'Path to your xcarchive file. Optional if you use the `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE],
                                       optional: true,
                                       env_name: 'ESTIMATE_APPSTORE_SIZES_ARCHIVE_PATH',
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find xcarchive file at path '#{value}'") if !Helper.test? && !File.exist?(value)
                                       end)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
