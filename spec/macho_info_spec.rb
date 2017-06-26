describe Fastlane::Helper::MachoInfo do
  context "for all variants" do
    include_examples "variants"
    it 'executables return right encryption segments' do
      binaries.each do |bin, segs|
        macho_info = Fastlane::Helper::MachoInfo.new(File.join(binpath, bin))
        expect(macho_info.encryption_segments).to match_array(segs)
      end
    end
  end
end
