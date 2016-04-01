module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:, response_object:)
      @endpoint = endpoint
      @body = body.to_json
      @response_object = response_object
    end

    def run
      response_object.load(run_request)
      response_object
    end

    def run_request
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      raw_response = http.request(request)
      {
        httpok: raw_response.code_type == Net::HTTPOK,
        http_response_code: raw_response.code,
        raw_body: raw_response.body
      }
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
      @uri ||= URI.parse("#{root_uri}/#{endpoint}")
    end

    def root_uri
      if Vantiv::Environment.production?
        "https://apis.vantiv.com"
      elsif Vantiv::Environment.certification?
        "https://apis.cert.vantiv.com"
      end
    end
  end
end
