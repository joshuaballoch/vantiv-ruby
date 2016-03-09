module Vantiv
  class Api::Request

    attr_reader :body

    def initialize(endpoint:, body:, response_class: Api::Response)
      @endpoint = endpoint
      @body = build_request_body(body)
      @response_class = response_class
    end

    def run
      validate_env_variables_exist
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

    def build_request_body(body)
      request_body_base.merge(body).to_json
    end

    def request_body_base
      {
        "Credentials" => {
          "AcceptorID" => Vantiv.acceptor_id
        },
        "Reports" => {
          # NOTE: this is required by vantiv, so a default is left here.
          #       If a user wants to use this Vantiv feature, it can be made dynamic.
          "ReportGroup" => Vantiv.default_report_group
        },
        "Application" => {
          "ApplicationID" => Vantiv.application_id
        }
      }
    end

    def uri
      @uri ||= URI.parse("https://apis.cert.vantiv.com/#{endpoint}")
    end

    def validate_env_variables_exist
      required_vars = %w(acceptor_id application_id license_id default_report_group)

      missing_vars = required_vars.select do |v|
        value = Vantiv.send(:"#{v}")
        value == nil || value == ""
      end

      raise "Missing required Vantiv Configs: #{missing_vars.join(', ')}" if missing_vars.any?
    end
  end
end
