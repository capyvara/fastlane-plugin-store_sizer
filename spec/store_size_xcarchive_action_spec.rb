describe Fastlane::Actions::StoreSizeXcarchiveAction do
  let(:tmp_path) { Dir.mktmpdir }
  let(:export_fixtures_path) { "./spec/fixtures/export" }

  def make_fake_xcarchive(binary, archive_path)
    app_path = File.join(archive_path, "Products", "Applications", "Product.app")
    FileUtils.mkpath(app_path)
    FileUtils.cp(binary, File.join(app_path, "Product"))
  end

  context "for all variants" do
    include_examples "variants"
    it 'produces a report' do
      require 'plist'
      allow(Fastlane::Helper::StoreSizerHelper).to receive(:xcode_export_package) do |archive_path, export_options_plist_path, export_path|
        expect(File.directory?(archive_path)).to be_truthy
        expect(File.exist?(export_options_plist_path)).to be_truthy

        export_options = Plist.parse_xml(export_options_plist_path)
        expect(export_options).to include("method" => 'ad-hoc', "thinning" => '<thin-for-all-variants>')

        FileUtils.mkpath(export_path)
        FileUtils.cp(File.join(export_fixtures_path, "App Thinning Size Report.txt"), export_path)
        FileUtils.cp(File.join(export_fixtures_path, "app-thinning.plist"), export_path)
      end

      expected_result = Plist.parse_xml(File.join(export_fixtures_path, "app-thinning.plist"))

      binaries.each do |bin, segs|
        archive_path = File.join(tmp_path, bin + ".xcarchive")
        make_fake_xcarchive(File.join(binpath, bin), archive_path)
        result = Fastlane::Actions::StoreSizeXcarchiveAction.run(archive_path: archive_path)
        expect(result).to eq(expected_result)
      end
    end
  end
  after do
    FileUtils.rm_rf(tmp_path)
  end
end
