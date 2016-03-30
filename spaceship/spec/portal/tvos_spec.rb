require 'spec_helper'

describe Spaceship::ProvisioningProfile do
  describe "tvOS Profiles" do
    before do
      Spaceship.login
    end
    let(:client) { Spaceship::ProvisioningProfile.client }

    describe "Create a new Development Profile" do
      it "uses the correct type for the create request" do
        cert = Spaceship::Certificate::Development.all.first
        result = Spaceship::ProvisioningProfile::Development.create_tvos!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: cert)
        expect(result.raw_data['provisioningProfileId']).to eq('W2MY88F6GE')
      end
    end
  end
end