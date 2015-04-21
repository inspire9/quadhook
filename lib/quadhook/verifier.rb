class Quadhook::Verifier
  def initialize(request, api_key, uri)
    @request, @api_key, @uri = request, api_key, uri
  end

  def call
    hmac == header
  end

  private

  attr_reader :request, :api_key, :uri

  def body
    request.body.rewind
    request.body.read
  end

  def data
    "#{uri}#{params.sort.flatten.join}"
  end

  def digest
    OpenSSL::Digest.new 'sha1'
  end

  def header
    request.env['HTTP_X_QUADERNO_SIGNATURE'] ||
    request.env['X-Quaderno-Signature']
  end

  def hmac
    Base64.encode64(
      OpenSSL::HMAC.digest(digest, api_key, data)
    ).strip
  end

  def params
    @params ||= begin
      JSON.parse body
    rescue JSON::ParserError
      {}
    end
  end
end
