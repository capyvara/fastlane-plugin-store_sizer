describe Fastlane::Actions::StoreSizeXcarchiveCheckAction do
  let(:thinning_report) { Plist.parse_xml(File.join("./spec/fixtures/export", "app-thinning.plist")) }

  def make_segments_report(min_os_version, text_segments_size, text_max_slice_size)
    result = {}
    result["min_os_version"] = min_os_version
    result["text_segments_size"] = text_segments_size
    result["text_max_slice_size"] = text_max_slice_size
    result
  end

  context "check Apple constraints" do
    it 'breaks if ios <= 6 and size exceed' do
      report = make_segments_report([6, 0, 0], Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_TEXT_6_LESS + 1, 0)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
    end

    it 'breaks if 7 <= ios <= 8 and size exceed' do
      report = make_segments_report([7, 0, 0], 0, Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_SEGMENT_7_TO_8 + 1)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)

      report = make_segments_report([8, 0, 0], 0, Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_SEGMENT_7_TO_8 + 1)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
    end

    it 'breaks if ios >= 9 and size exceed' do
      report = make_segments_report([9, 0, 0], Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_TEXT_9_PLUS + 1, 0)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
    end

    it 'pass if ios <= 6 and size fits' do
      report = make_segments_report([6, 0, 0], Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_TEXT_6_LESS, 0)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.not_to raise_error
    end

    it 'pass if 7 <= ios <= 8 and size fits' do
      report = make_segments_report([7, 0, 0], 0, Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_SEGMENT_7_TO_8)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.not_to raise_error

      report = make_segments_report([8, 0, 0], 0, Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_SEGMENT_7_TO_8)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.not_to raise_error
    end

    it 'pass if ios >= 9 and size fits' do
      report = make_segments_report([9, 0, 0], Fastlane::Actions::StoreSizeXcarchiveCheckAction::MAX_TEXT_9_PLUS, 0)
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: report, max_wifi_size: 0) }.not_to raise_error
    end
  end

  context "check Wi-Fi sizes" do
    it 'breaks if download size exceeds, ignore universal' do
      max = thinning_report["variants"].reject { |n, v| v["variantIds"].nil? }.map { |n, v| v["sizeCompressedApp"] }.max
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: thinning_report, max_wifi_size: max - 1, ignore_universal: true) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
    end

    it 'breaks if download size exceeds, check universal' do
      max = thinning_report["variants"].map { |n, v| v["sizeCompressedApp"] }.max
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: thinning_report, max_wifi_size: max - 1, ignore_universal: false) }.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
    end

    it 'pass if download size fits, ignore universal' do
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: thinning_report, ignore_universal: true) }.not_to raise_error
    end

    it 'pass if download size fits, check universal' do
      expect { Fastlane::Actions::StoreSizeXcarchiveCheckAction.run(report: thinning_report, ignore_universal: false) }.not_to raise_error
    end
  end
end
