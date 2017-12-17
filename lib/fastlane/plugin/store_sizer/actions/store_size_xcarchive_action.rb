module Fastlane
  module Actions
    module SharedValues
      SIZE_REPORT = :SIZE_REPORT
    end

    class StoreSizeXcarchiveAction < Action
      EXTRA_FILE_SIZE = 2_000_000

      def self.run(params)
        require 'plist'

        unless Fastlane::Helper.test?
          UI.user_error!("xcodebuild not installed") if `which xcodebuild`.length == 0
        end

        archive_path = params[:archive_path] || Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE]
        app_path = Dir.glob(File.join(archive_path, "Products", "Applications", "*.app")).first
        UI.user_error!("No applications found in archive") if app_path.nil?

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

            macho_info = Helper::MachoInfo.new(binary_path)

            Helper::StoreSizerHelper.write_random_segments(binary_path, macho_info.encryption_segments)
            Helper::StoreSizerHelper.write_random_file(extra_file_path, EXTRA_FILE_SIZE)

            export_options = {}
            export_options['method'] = 'ad-hoc'
            export_options.merge!(Plist.parse_xml(params[:export_plist])) if params[:export_plist]
            export_options['thinning'] = params[:thinning]
            export_options_plist_path = File.join(tmp_path, "ExportOptions.plist")
            File.write(export_options_plist_path, Plist::Emit.dump(export_options, false))

            UI.message("Exporting all variants of #{archive_path} for estimation...")
            Helper::StoreSizerHelper.xcode_export_package(archive_path, export_options_plist_path, export_path)

            UI.verbose(File.read(File.join(export_path, "App Thinning Size Report.txt")))

            result = Plist.parse_xml(File.join(export_path, "app-thinning.plist"))
            result.merge!(macho_info.sizes_info)
          ensure
            FileUtils.rm_f(binary_path)
            FileUtils.mv(binary_backup_path, binary_path)
            FileUtils.rm_f(extra_file_path)
          end
        end

        Actions.lane_context[SharedValues::SIZE_REPORT] = result
        result
      end

      def self.description
        "Estimates download and install sizes for your app"
      end

      def self.authors
        ["Marcelo Oliveira"]
      end

      def self.output
        [
          ['SIZE_REPORT', 'The generated size report hash']
        ]
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
                                       env_name: 'STORE_SIZE_ARCHIVE_PATH',
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find xcarchive file at path '#{value}'") if !Helper.test? && !File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :export_plist,
                                       description: 'Path to your existing export options plist with the codesigning stuff',
                                       default_value: nil,
                                       optional: true,
                                       env_name: 'STORE_SIZE_EXPORT_OPTIONS_PLIST',
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find plist file at path '#{value}'") if !Helper.test? && !File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :thinning,
                                       description: 'How should Xcode thin the package? e.g. <none>, <thin-for-all-variants>, or a model identifier for a specific device (e.g. "iPhone7,1")',
                                       default_value: '<thin-for-all-variants>',
                                       optional: true,
                                       env_name: 'STORE_SIZE_THINNING')
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end

