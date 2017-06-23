module Fastlane
  module Helper
    class StoreSizerHelper
      def self.write_random_encryption_segments(binary_path)
        segments = encryption_segments(binary_path)
        File.open(binary_path, "rb+") do |file|
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

      def self.encryption_segments(binary_path)
        require 'macho'

        segments = []

        file = MachO.open(binary_path)
        if file.kind_of?(MachO::FatFile)
          file.fat_archs.each_index do |arch_index|
            segment = macho_encryption_segment(file.machos[arch_index], file.fat_archs[arch_index].offset)
            segments.push(segment) unless segment.nil?
          end
        elsif file.kind_of?(MachO::MachOFile)
          segment = macho_encryption_segment(file, 0)
          segments.push(segment) unless segment.nil?
        end
        segments
      end

      def self.macho_encryption_segment(macho, file_offset)
        encryption_info = (macho.magic32? ? macho[:LC_ENCRYPTION_INFO] : macho[:LC_ENCRYPTION_INFO_64]).first
        return nil if encryption_info.nil?
        [file_offset + encryption_info.cryptoff, encryption_info.cryptsize]
      end
    end
  end
end
