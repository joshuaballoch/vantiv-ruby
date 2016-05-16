require 'spec_helper'

describe "account updater" do
  let(:payment_account_id) { test_account.payment_account_id }

  subject(:response) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: "1234",
      order_id: "SomeOrder123",
      expiry_month: test_account.expiry_month,
      expiry_year: test_account.expiry_year
    )
  end

  context "no account updater" do
    let(:test_account) { Vantiv::TestAccount.valid_account }

    it "returns nil account updater response" do
      expect(response.account_updater_response).to eq nil
    end

  end

  context "success" do
    let(:test_account) { Vantiv::TestAccount.account_updater }

    it "returns success" do
      expect(response.success?).to eq true
    end

    it "returns a transaction ID" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns updated payment_account_id" do
      expect(response.account_updater_response.payment_account_id).not_to eq nil
      expect(response.account_updater_response.payment_account_id).not_to eq ""
    end

    it "returns updated card_type" do
      expect(response.account_updater_response.card_type).to eq "MC"
    end

    it "returns updated expiry month" do
      expect(response.account_updater_response.expiry_month).to eq "01"
    end

    it "returns updated expiry year" do
      expect(response.account_updater_response.expiry_year).to eq "15"
    end

    it "enables using the payment account id for subsequent transactions" do
      payment_account_id = response.account_updater_response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah",
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
      expect(auth_response.success?).to eq true
    end

    it "returns an 000 response code" do
      expect(response.response_code).to eq('000')
    end
  end

  context "account closed" do
    let(:test_account) { Vantiv::TestAccount.account_updater_account_closed }

    it "returns success" do
      puts response.body
      expect(response.success?).to eq true
    end

    it "returns an 000 (success) response code" do
      expect(response.response_code).to eq('000')
    end

    it "returns a transaction ID" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns updated payment_account_id" do
      expect(response.account_updater_response.payment_account_id).not_to eq nil
      expect(response.account_updater_response.payment_account_id).not_to eq ""
    end

    it "returns updated card_type" do
      expect(response.account_updater_response.card_type).to eq "VI"
    end

    it "returns updated expiry month" do
      expect(response.account_updater_response.expiry_month).to eq "11"
    end

    it "returns updated expiry year" do
      expect(response.account_updater_response.expiry_year).to eq "99"
    end

    it "returns extended card 501 (account closed) response code" do
      expect(response.account_updater_response.extended_card_response_code).to eq('501')
    end

    it "returns extended card response message" do
      expect(response.account_updater_response.extended_card_response_message).to eq('The account was closed')
    end
  end

end
