module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:, response_object:)
      @endpoint = endpoint
      @body = body.to_json
      @response_object = response_object
    end

    def run
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      response_object.load(http.request(request))
      response_object
    end

    private

    attr_reader :endpoint, :response_object

    def header
      {
        "Content-Type" =>"application/json",
        "Authorization" => "VANTIV license=\"#{Vantiv.license_id}\""
      }
    end

    def uri
      @uri ||= URI.parse("https://apis.cert.vantiv.com/#{endpoint}")
    end
  end
end
