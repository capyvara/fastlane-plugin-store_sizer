module Fastlane
  module Helper
    class StoreSizerHelper
      def self.write_random_encryption_segments(binary_path)
        segments = estimated_encryption_segments(binary_path)
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

      def self.xcode_export_package(archive_path, export_options_plist_path, export_dir)
        command = "xcodebuild"
        command << " -exportArchive"
        command << " -exportOptionsPlist #{export_options_plist_path}"
        command << " -archivePath #{archive_path}"
        command << " -exportPath #{export_dir}"
        #FastlaneCore::CommandExecutor.execute(command: command, print_command: false, print_all: false)
        Fastlane::Actions.sh(command, log: false);
      end

      private

      def self.align_next(offset, align)
        return (offset + (align - 1)) - ((offset + (align - 1)) % align)
      end

      def self.estimated_encryption_segments(binary_path)
        require 'macho'

        segments = []
        file = MachO.open(binary_path)
        file.fat_archs.each_index do |arch_index|
          fat_arch = file.fat_archs[arch_index]
          macho = file.machos[arch_index]
          macho.segments.each do |segment|
            next unless segment.segname == "__TEXT"
            start_offset = align_next(fat_arch.offset + segment.fileoff + macho.header.sizeofcmds, 1 << fat_arch.align);
            end_offset = fat_arch.offset + segment.fileoff + segment.filesize;
            segments.push([start_offset, end_offset - start_offset])
          end
        end
        return segments;
      end
    end
  end
end
