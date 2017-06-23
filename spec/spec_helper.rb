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
    binaries["armv7"] = [[16384, 16384]]
    binaries["arm64"] = [[16384, 16384]]
    binaries["fat-armv7-arm64"] = [[32768, 16384], [98304, 16384]]
    binaries["i386"] = []
    binaries["x86_64"] = []
    binaries["fat-i386-x86_64"] = []
    return binaries
  end

  let(:binpath) { "./spec/fixtures/bin/" }
end