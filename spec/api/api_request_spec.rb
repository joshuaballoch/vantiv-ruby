require 'spec_helper'

describe Vantiv::Api::Request do
  subject(:run_api_request) do
    Vantiv::Api::Request.new(
      endpoint: Vantiv::Api::Endpoints::TOKENIZATION,
      body: Vantiv::Api::TokenizationRequestBody.generate(
        paypage_registration_id: "1234"
      ),
      response_class: Vantiv::Api::Response
    ).run
  end

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

  context "running an API request if License ID not configured" do
    let(:missing_vars) { ['license_id'] }

    it "raises an error" do
      expect{run_api_request}.to raise_error(/missing.*LICENSE_ID/i)
    end
  end

  context "running an API request application id not configured correctly" do
    let(:missing_vars) { ['application_id'] }

    it "raises an error" do
      expect{run_api_request}.to raise_error(/missing.*application_id/i)
    end
  end

  context "running an API request if Acceptor ID not configured" do
    let(:missing_vars) { ['acceptor_id'] }

    it "raises an error" do
      expect{run_api_request}.to raise_error(/missing.*acceptor_id/i)
    end
  end

  context "running an API request if default report group not configured" do
    let(:missing_vars) { ['default_report_group'] }

    it "raises an error" do
      expect{run_api_request}.to raise_error(/missing.*default_report_group/i)
    end
  end

end
