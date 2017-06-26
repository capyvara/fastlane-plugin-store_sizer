module Fastlane
  module Helper
    class StoreSizerHelper
      def self.write_random_segments(file_path, segments)
        File.open(file_path, "rb+") do |file|
          segments.each do |segment|
            file.pos = segment[0]
            file.puts(SecureRandom.random_bytes(segment[1]))
          end
        end
      end

      def self.write_random_file(path, size)
        IO.binwrite(path, SecureRandom.random_bytes(size))
      end

      def self.xcode_export_package(archive_path, export_options_plist_path, export_path)
        command = "xcodebuild"
        command << " -exportArchive"
        command << " -exportOptionsPlist #{export_options_plist_path}"
        command << " -archivePath #{archive_path}"
        command << " -exportPath #{export_path}"
        FastlaneCore::CommandExecutor.execute(command: command, print_command: false, print_all: false)
      end
    end
  end
end
