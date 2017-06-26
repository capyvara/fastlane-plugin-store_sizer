$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/store_sizer' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

RSpec.shared_examples "variants" do
  let(:binaries) do
    binaries = {}
    binaries["armv7"] = { encryption_segments: [[16_384, 16_384]], text_segments_size: 32_768, text_max_slice_size: 32_768 }
    binaries["arm64"] = { encryption_segments: [[16_384, 16_384]], text_segments_size: 32_768, text_max_slice_size: 32_768 }
    binaries["fat-armv7-arm64"] = { encryption_segments: [[32_768, 16_384], [98_304, 16_384]], text_segments_size: 65_536, text_max_slice_size: 32_768 }
    binaries["i386"] = { encryption_segments: [], text_segments_size: 4096, text_max_slice_size: 4096 }
    binaries["x86_64"] = { encryption_segments: [], text_segments_size: 4096, text_max_slice_size: 4096 }
    binaries["fat-i386-x86_64"] = { encryption_segments: [], text_segments_size: 8192, text_max_slice_size: 4096 }
    return binaries
  end

  let(:binpath) { "./spec/fixtures/bin/" }
end
