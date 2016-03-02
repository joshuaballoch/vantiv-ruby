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
    # TODO: how do we get this going forward?
    let(:payment_account_id) { "1111000194360009" }

    it "returns success response" do
      response = run_auth
      expect(response.success?).to eq true
    end

    it "returns a transaction ID" do
      response = run_auth
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    pending "should we test auth code?"
  end

  context "on an account with insufficient funds" do
    # TODO: how do we get this going forward?
    let(:payment_account_id) { "1111000189340008" }

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
    # TODO: how do we get this going forward?
    let(:payment_account_id) { "1112000189130002" }

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
    let(:payment_account_id) { "111300188100003" }

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
end
