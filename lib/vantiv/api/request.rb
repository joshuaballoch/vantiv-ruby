module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:, response_class: Api::Response)
      @endpoint = endpoint
      @body = body.to_json
      @response_class = response_class
    end

    def run
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      response_class.new(http.request(request))
    end

    private

    attr_reader :endpoint, :response_class

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
