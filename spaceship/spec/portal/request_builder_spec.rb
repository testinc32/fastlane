require 'spec_helper'

describe Spaceship::Portal::RequestBuilder do
  before { Spaceship.login }
  let(:client) { Spaceship::Device.client }
  let(:request_builder) { Spaceship::Portal::RequestBuilder.new(client) }

  it 'should construct a URL' do
    uri = request_builder.ios.identifiers.get('listAppIds.action').uri
    expect(uri.to_s).to eq('https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listAppIds.action')
    # show we can partially update our builder
    uri = request_builder.mac.uri
    expect(uri.to_s).to eq('https://developer.apple.com/services-account/QH65B2/account/mac/identifiers/listAppIds.action')
  end
end
