describe Fastlane::Actions::XcframeworkAction do
  describe '#run' do
    it 'should fail if no parameters are given' do
      expect(Fastlane::Actions::XcframeworkAction.run(nil)).to eq(nil)
    end
  end
end
