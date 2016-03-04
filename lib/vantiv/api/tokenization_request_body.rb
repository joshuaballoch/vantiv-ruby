module Vantiv
  module Api
    class TokenizationRequestBody
      def self.generate(paypage_registration_id:)
        new(paypage_registration_id: paypage_registration_id).to_hash
      end

      attr_reader :paypage_registration_id

      def initialize(paypage_registration_id:)
        @paypage_registration_id = paypage_registration_id
      end

      def to_hash
        {
          "Card" => {
            "PaypageRegistrationID" => paypage_registration_id
          }
        }
      end
    end
  end
end
