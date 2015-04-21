class Quadhook::Endpoint
  delegate :instrument, to: ActiveSupport::Notifications

  def initialize(api_key, uri)
    @api_key, @uri = api_key, uri
  end

  def call(env)
    request = Rack::Request.new env

    if Quadhook::Verifier.new(request, api_key, uri).call
      json = json_from_body request

      instrument 'notification.quadhook.webhook',
        event_type: json['event_type'],
        data:       json['data']

      [200, {}, ['']]
    else
      [400, {}, ['']]
    end
  end

  private

  attr_reader :api_key, :uri

  def json_from_body(request)
    request.body.rewind

    JSON.parse request.body.read
  end
end
