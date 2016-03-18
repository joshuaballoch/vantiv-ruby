require 'securerandom'

module Vantiv
  module Api
    class RequestBodyGenerator
      def self.run(*args)
        new(*args).run
      end

      def initialize(*args)
        @body_parts = args
      end

      def run
        body = request_body_base
        body_parts.each do |body_part|
          body.merge!(body_part)
        end
        body
      end

      private

      attr_accessor :body_parts

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
            "ApplicationID" => SecureRandom.hex(12)
          }
        }
      end
    end
  end
end
