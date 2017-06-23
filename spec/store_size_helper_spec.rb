describe Fastlane::Helper::StoreSizerHelper do
  context "for all variants" do
    include_examples "variants"
    it 'executables return right encryption segments' do
      binaries.each do |bin, segs|
        segments = Fastlane::Helper::StoreSizerHelper.encryption_segments(File.join(binpath, bin))
        expect(segments).to match_array(segs)
      end
    end
  end
end
