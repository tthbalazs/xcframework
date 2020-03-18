describe Fastlane::Actions::XcframeworkAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The xcframework plugin is working!")

      Fastlane::Actions::XcframeworkAction.run(nil)
    end
  end
end
