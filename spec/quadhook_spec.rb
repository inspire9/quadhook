require 'spec_helper'

RSpec.describe 'Quadhook Notifications' do
  include Rack::Test::Methods

  let(:app)           { Quadhook::Endpoint.new 'SUPERSECRET', 'uri' }
  let(:subscriptions) { [] }

  def subscribe(&block)
    subscriptions << ActiveSupport::Notifications.subscribe(
      'notification.quadhook.webhook', &block
    )
  end

  def hmac_for(params)
    query_string = Rack::Utils.build_nested_query params
    flat_params  = Rack::Utils.parse_query query_string
    prehashed_string = flat_params.keys.sort.inject('uri') do |string, key|
      string << key << flat_params[key]
    end

    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'), 'SUPERSECRET', prehashed_string
      )
    ).strip
  end

  def post_with_hmac(path, params = {}, headers = {})
    post path, params, headers.merge(
      'HTTP_X_QUADERNO_SIGNATURE' => hmac_for(params)
    )
  end

  after :each do
    subscriptions.each do |subscription|
      ActiveSupport::Notifications.unsubscribe(subscription)
    end
  end

  it 'returns a 200' do
    post_with_hmac '/'

    expect(last_response.status).to eq(200)
  end

  it 'fires an event' do
    notification = false
    subscribe { |*args| notification = true }

    post_with_hmac '/'

    expect(notification).to eq(true)
  end

  it 'includes the body details' do
    subscribe { |*args|
      event = ActiveSupport::Notifications::Event.new *args
      expect(event.payload[:event_type]).to eq('test')
      expect(event.payload[:data]).to eq([{'foo' => 'bar'}])
    }

    post_with_hmac '/', event_type: "test", data: {foo: "bar"}
  end

  it 'accepts a dashed HMAC header' do
    post '/', {}, {'X-Quaderno-Signature' => hmac_for({})}

    expect(last_response.status).to eq(200)
  end

  context 'with invalid HMAC' do
    it 'returns a 400' do
      post '/'

      expect(last_response.status).to eq(400)
    end

    it 'does not fire an event' do
      notification = false
      subscribe { |*args| notification = true }

      post '/'

      expect(notification).to eq(false)
    end
  end
end
