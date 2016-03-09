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
      body: Vantiv::Api::TokenizationRequestBody.generate(
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

  context "running API requests when configs are missing" do
    let(:missing_vars) { {} }

    before :each do
      @cached_config = {}
      missing_vars.each do |config_var|
        @cached_config[config_var] = Vantiv.send(:"#{config_var}")
        Vantiv.configure do |config|
          config.send(:"#{config_var}=", nil)
        end
      end
    end

    after :each do
      missing_vars.each do |config_var|
        Vantiv.configure do |config|
          config.send(:"#{config_var}=", @cached_config[config_var])
        end
      end
    end

    context "if License ID not configured" do
      let(:missing_vars) { ['license_id'] }

      it "raises an error" do
        expect{run_api_request}.to raise_error(/missing.*LICENSE_ID/i)
      end
    end

    context "if application id not configured correctly" do
      let(:missing_vars) { ['application_id'] }

      it "raises an error" do
        expect{run_api_request}.to raise_error(/missing.*application_id/i)
      end
    end

    context "if Acceptor ID not configured" do
      let(:missing_vars) { ['acceptor_id'] }

      it "raises an error" do
        expect{run_api_request}.to raise_error(/missing.*acceptor_id/i)
      end
    end

    context "if default report group not configured" do
      let(:missing_vars) { ['default_report_group'] }

      it "raises an error" do
        expect{run_api_request}.to raise_error(/missing.*default_report_group/i)
      end
    end
  end
end
