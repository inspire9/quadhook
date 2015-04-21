class Quadhook::Endpoint
  delegate :instrument, to: ActiveSupport::Notifications

  def initialize(api_key, uri)
    @api_key, @uri = api_key, uri
  end

  def call(env)
    request = Rack::Request.new env

    if Quadhook::Verifier.new(request, api_key, uri).call
      request.body.rewind

      instrument 'notification.quadhook.webhook',
        event_type: request.params['event_type'],
        data:       request.params['data']

      [200, {}, ['']]
    else
      [400, {}, ['']]
    end
  end

  private

  attr_reader :api_key, :uri
end
