module Vantiv
  module Api
    class TokenizationRequestBody
      def self.generate(paypage_registration_id:)
        RequestBody.generate(
          new(paypage_registration_id: paypage_registration_id).body
        )
      end

      attr_reader :paypage_registration_id

      def initialize(paypage_registration_id:)
        @paypage_registration_id = paypage_registration_id
      end

      def body
        {
          "Card" => {
            "PaypageRegistrationID" => paypage_registration_id
          }
        }
      end
    end
  end
end
