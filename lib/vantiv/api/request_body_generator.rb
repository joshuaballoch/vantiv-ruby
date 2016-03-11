module Vantiv
  module Api
    class RequestBody

      def self.generate(inner_body)
        new(inner_body).generate
      end

      def initialize(inner_body)
        @inner_body = inner_body
      end

      def generate
        request_body_base.merge(inner_body)
      end

      private

      attr_accessor :inner_body

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

    end
  end
end
