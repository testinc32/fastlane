describe Fastlane do
  describe Fastlane::Action do
    describe "#action_name" do
      it "converts the :: format to a readable one" do
        expect(Fastlane::Actions::IpaAction.action_name).to eq('ipa')
        expect(Fastlane::Actions::IncrementBuildNumberAction.action_name).to eq('increment_build_number')
      end
    end

    describe "Call another action from an action" do
      it "allows the user to call it using `other_action.rocket`" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileActionFromAction')

        response = {
          rocket: "🚀",
          pwd: Dir.pwd
        }
        expect(ff.runner.execute(:something, :ios)).to eq(response)
      end

      it "shows an appropriate error message when trying to directly call an action" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileActionFromActionInvalid')
        expect do
          ff.runner.execute(:something, :ios)
        end.to raise_error("To call another action from an action use `OtherAction.rocket` instead")
      end
    end
  end
end
