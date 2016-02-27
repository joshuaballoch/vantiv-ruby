module Vantiv
  module Api
    class AuthorizationResponse < Api::Response
      def success?
        !failure?
      end

      def failure?
        api_level_failure? || authorization_successful?
      end

      private

      def authorization_successful?
        # TODO: review API docs and update this
        litle_response_code == '000'
      end

      def authorization_unsuccessful?
        !authorization_successful?
      end
    end
  end
end
