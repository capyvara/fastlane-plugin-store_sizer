describe Fastlane::Actions::StoreSizerAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The store_sizer plugin is working!")

      Fastlane::Actions::StoreSizerAction.run(nil)
    end
  end
end
