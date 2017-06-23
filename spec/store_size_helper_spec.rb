describe Fastlane::Helper::StoreSizerHelper do
  it 'executables return right encryption segments' do
    binaries = {}
    binaries["armv7"] = [[16384, 16384]]
    binaries["arm64"] = [[16384, 16384]]
    binaries["fat-armv7-arm64"] = [[32768, 16384], [98304, 16384]]
    binaries["i386"] = []
    binaries["x86_64"] = []
    binaries["fat-i386-x86_64"] = []

    binaries.each do |bin, segs| 
      segments = Fastlane::Helper::StoreSizerHelper.encryption_segments(File.join("./spec/fixtures/bin/", bin))
      expect(segments).to match_array(segs)
    end
  end
end
