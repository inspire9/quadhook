require 'spec_helper'

RSpec.describe 'Quadhook Notifications' do
  include Rack::Test::Methods

  DIGEST = OpenSSL::Digest.new('sha1')

  let(:app)           { Quadhook::Endpoint.new 'SUPERSECRET', 'uri' }
  let(:subscriptions) { [] }

  def subscribe(&block)
    subscriptions << ActiveSupport::Notifications.subscribe(
      'notification.quadhook.webhook', &block
    )
  end

  def hmac_for(body)
    payload = JSON.parse(body).sort.flatten.join

    Base64.encode64(
      OpenSSL::HMAC.digest(DIGEST, 'SUPERSECRET', "uri#{payload}")
    ).strip
  end

  def post_with_hmac(path, body = '{"foo":"bar"}', headers = {})
    post path, body, headers.merge(
      'HTTP_X_QUADERNO_SIGNATURE' => hmac_for(body)
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
      expect(event.payload[:data]).to eq({'foo' => 'bar'})
    }

    post_with_hmac '/', {event_type: "test", data: {foo: "bar"}}.to_json
  end

  it 'accepts a dashed HMAC header' do
    post '/', '{"foo":"bar"}',
      {'X-Quaderno-Signature' => hmac_for('{"foo":"bar"}')}

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
