require 'spec_helper'

describe "auth" do
  let(:customer_external_id) { "1234" }
  let(:payment_account_id) { test_account.payment_account_id }

  subject(:run_auth) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: customer_external_id,
      order_id: "SomeOrder123",
      expiry_month: "01",
      expiry_year: "16"
    )
  end

  context "on a valid account" do
    let(:test_account) { Vantiv::TestAccount.valid_account }

    it "returns success response" do
      response = run_auth
      expect(response.success?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a '000' response code" do
      response = run_auth
      expect(response.response_code).to eq('000')
    end
  end

  context "on an account with insufficient funds" do
    let(:test_account) { Vantiv::TestAccount.insufficient_funds }

    it "returns a failure response" do
      response = run_auth
      expect(response.success?).to eq false
      expect(response.failure?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "gives a human readable reason" do
      response = run_auth
      expect(response.message).to match(/insufficient funds/i)
    end

    it "notifies that it is insufficient funds" do
      response = run_auth
      expect(response.insufficient_funds?).to eq true
    end

    it "returns a '110' response code" do
      response = run_auth
      expect(response.response_code).to eq('110')
    end
  end

  context "on an account with an invalid account number" do
    let(:test_account) { Vantiv::TestAccount.invalid_account_number }

    it "returns a failure response" do
      response = run_auth
      expect(response.success?).to eq false
      expect(response.failure?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "gives a human readable reason" do
      response = run_auth
      expect(response.message).to match(/invalid account number/i)
    end

    it "responds to invalid_account_number?" do
      response = run_auth
      expect(response.invalid_account_number?).to eq true
    end

    it "returns a '301' response code" do
      response = run_auth
      expect(response.response_code).to eq('301')
    end
  end

  context "on an account with misc errors, like pick up card" do
    let(:test_account) { Vantiv::TestAccount.pick_up_card }

    it "returns a failure response" do
      response = run_auth
      expect(response.success?).to eq false
      expect(response.failure?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "gives a human readable reason" do
      response = run_auth
      expect(response.message).not_to eq nil
      expect(response.message).not_to eq ""
    end

    it "returns a '303' response code" do
      response = run_auth
      expect(response.response_code).to eq('303')
    end
  end

  context "when API level failure occurs" do
    let(:test_account) { Vantiv::TestAccount.valid_account }

    before do
      @license_id = Vantiv.license_id
      Vantiv.license_id = "invalid"
    end

    after do
      Vantiv.license_id = @license_id
    end

    it "responds that the authorization failed" do
      response = run_auth
      expect(response.failure?).to eq true
      expect(response.api_level_failure?).to eq true
    end
  end
end
