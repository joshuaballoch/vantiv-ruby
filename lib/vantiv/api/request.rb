module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:, response_object:)
      @endpoint = endpoint
      @body = body.to_json
      @response_object = response_object
      self.retry_count = 0
    end

    def run
      vantiv_response = run_request_with_retries
      response_object.load(vantiv_response)
      response_object
    end

    def run_request
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      raw_response = http.request(request)
      parsed_body = JSON.parse(raw_response.body)
      {
        httpok: raw_response.code_type == Net::HTTPOK,
        http_response_code: raw_response.code,
        body: parsed_body
      }
    end

    private

    attr_reader :endpoint, :response_object
    attr_accessor :retry_count

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

    def max_retries_exceeded?
      retry_count > 3
    end

    def run_request_with_retries
      begin
        run_request
      rescue JSON::ParserError => e
        self.retry_count += 1
        if max_retries_exceeded?
          raise e
        else
          run_request_with_retries
        end
      end
    end
  end
end
