require 'macho'

module Fastlane
  module Helper
    class MachoInfo
      attr_accessor :min_os_versions
      attr_accessor :encryption_segments
      attr_accessor :text_segment_sizes

      def initialize(binary_path)
        self.min_os_versions = []
        self.encryption_segments = []
        self.text_segment_sizes = []

        file = MachO.open(binary_path)
        if file.kind_of?(MachO::FatFile)
          file.fat_archs.each_index do |arch_index|
            macho_add(file.machos[arch_index], file.fat_archs[arch_index].offset)
          end
        elsif file.kind_of?(MachO::MachOFile)
          macho_add(file, 0)
        end
      end

      def self.split_version(version)
        binary = format("%032b", version)
        return [
          binary[0..15], binary[16..23], binary[24..31]
        ].map { |s| s.to_i(2) }
      end

      def sizes_info
        result = {}
        result["min_os_version"] = self.min_os_versions.first
        result["text_segments_size"] = self.text_segment_sizes.flatten.reduce(0, :+)
        result["text_max_slice_size"] = self.text_segment_sizes.flatten.max
        result
      end

      def macho_add(macho, file_offset)
        encryption_info = (macho.magic32? ? macho[:LC_ENCRYPTION_INFO] : macho[:LC_ENCRYPTION_INFO_64]).first
        self.encryption_segments.push([file_offset + encryption_info.cryptoff, encryption_info.cryptsize]) unless encryption_info.nil?

        min_version_info = macho[:LC_VERSION_MIN_IPHONEOS].first
        self.min_os_versions.push(MachoInfo.split_version(min_version_info.version)) unless min_version_info.nil?

        text_segments = macho.segments.select { |seg| seg.segname == "__TEXT" }
        self.text_segment_sizes.push(text_segments.map(&:filesize)) unless text_segments.nil?
      end
    end
  end
end
