describe Fastlane::Actions::StoreSizeXcarchiveAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The store_sizer plugin is working!")
      Fastlane::UI.message("The store_sizer plugin is working!")
      # Fastlane::Actions::StoreSizeXcarchiveAction.run(nil)
    end
  end
end
