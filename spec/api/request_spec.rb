require 'spec_helper'

describe Vantiv::Api::Request do
  let(:general_response_class) do
    Class.new(Vantiv::Api::Response) do
      def transaction_response_name
        "tokenizationResponse"
      end
    end
  end

  subject(:run_api_request) do
    Vantiv::Api::Request.new(
      endpoint: Vantiv::Api::Endpoints::TOKENIZATION,
      body: Vantiv::Api::RequestBody.for_tokenization(
        paypage_registration_id: "1234"
      ),
      response_class: general_response_class
    ).run
  end

  context "running an API request when authentication fails" do
    before do
      @cached_license_id = Vantiv.license_id
      Vantiv.configure do |config|
        config.license_id = "asdfasdf"
      end
    end

    after do
      Vantiv.configure do |config|
        config.license_id = @cached_license_id
      end
    end

    it "does not raise errors on standard method retrieval" do
      response = run_api_request
      expect(response.message).to eq nil
      expect(response.response_code).to eq nil
      expect(response.transaction_id).to eq nil
    end

    it "returns an api level failure" do
      expect(run_api_request.api_level_failure?).to eq true
    end
  end
end
