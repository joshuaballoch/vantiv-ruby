module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:)
      @endpoint = endpoint
      @body = build_request_body(body)
    end

    def run
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      endpoint.response_class.new(http.request(request))
    end

    private

    attr_reader :endpoint

    def header
      {
        "Content-Type" =>"application/json",
        "Authorization" => "VANTIV license=\"#{Vantiv.license_id}\""
      }
    end

    def build_request_body(body)
      request_body_base.merge(body).to_json
    end

    def request_body_base
      {
        "Credentials" => {
          "AcceptorID" => Vantiv.acceptor_id
        },
        "Reports" => {
          # NOTE: this is required, so a default is left here.
          #       If a user wants to use this Vantiv feature, it can be made dynamic.
          "ReportGroup" => Vantiv.default_report_group
        },
        "Application" => {
          "ApplicationID" => Vantiv.application_id
        }
      }
    end

    def uri
      @uri ||= URI.parse("https://apis.cert.vantiv.com/#{endpoint.url}")
    end
  end
end
