require 'spec_helper'

describe "#auth" do
  let(:customer_external_id) { "1234" }

  subject(:run_auth) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: customer_external_id
    )
  end

  context "on a valid account" do
    let(:payment_account_id) { Vantiv::TestAccount.valid_account.payment_account_id }

    it "returns success response" do
      response = run_auth
      expect(response.success?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end
  end

  context "on an account with insufficient funds" do
    let(:payment_account_id) { Vantiv::TestAccount.insufficient_funds.payment_account_id }

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

    it "notifies that it is insufficient funds (110?)" do
      response = run_auth
      expect(response.insufficient_funds?).to eq true
    end
  end

  context "on an account with an invalid account number" do
    let(:payment_account_id) { Vantiv::TestAccount.invalid_account_number.payment_account_id }

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
  end

  context "on an account with misc errors, like pick up card" do
    let(:payment_account_id) { Vantiv::TestAccount.pick_up_card.payment_account_id }

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
  end

  context "when API level failure occurs" do
    let(:payment_account_id) { Vantiv::TestAccount.valid_account.payment_account_id }

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
