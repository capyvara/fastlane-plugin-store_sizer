describe Fastlane::Helper::MachoInfo do
  context "for all variants" do
    include_examples "variants"
    it 'executables return right encryption segments' do
      binaries.each do |bin, info|
        macho_info = Fastlane::Helper::MachoInfo.new(File.join(binpath, bin))
        expect(macho_info.encryption_segments).to match_array(info[:encryption_segments])
      end
    end
    it 'executables return correct sizes' do
      binaries.each do |bin, info|
        macho_info = Fastlane::Helper::MachoInfo.new(File.join(binpath, bin))
        expect(macho_info.sizes_info["min_os_version"]).to match_array([10, 3, 0])
        expect(macho_info.sizes_info["text_segments_size"]).to eq(info[:text_segments_size])
        expect(macho_info.sizes_info["text_max_slice_size"]).to eq(info[:text_max_slice_size])
      end
    end
  end
end
