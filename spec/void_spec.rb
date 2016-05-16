require 'spec_helper'

describe "processing voids" do
  let(:test_account) { Vantiv::TestAccount.valid_account }
  let(:payment_account_id) { test_account.payment_account_id }
  let(:customer_id) { "customer-#{rand(10000)}" }
  let(:order_id) { "order-#{rand(10000)}" }

  subject(:response) do
    Vantiv.void(
      transaction_id: prior_transaction.transaction_id
    )
  end

  context "on prior same-day captures" do
    let(:prior_transaction) do
      auth = Vantiv.auth(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
      Vantiv.capture(transaction_id: auth.transaction_id)
    end

    it "returns success when transaction is received" do
      expect(response.success?).to eq true
    end

    it "returns a new transaction id" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(response.response_code).to eq '001'
      expect(response.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day credits" do
    let(:prior_transaction) do
      sale = Vantiv.auth_capture(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
      Vantiv.credit(transaction_id: sale.transaction_id, amount: 5)
    end

    it "returns success when transaction is received" do
      expect(response.success?).to eq true
    end

    it "returns a new transaction id" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(response.response_code).to eq '001'
      expect(response.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day auth_capture (sale) transactions" do
    let(:prior_transaction) do
      Vantiv.auth_capture(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
    end

    it "returns success when transaction is received" do
      expect(response.success?).to eq true
    end

    it "returns a new transaction id" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(response.response_code).to eq '001'
      expect(response.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day refunds" do
    let(:prior_transaction) do
      Vantiv.refund(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
    end

    it "returns success when transaction is received" do
      expect(response.success?).to eq true
    end

    it "returns a new transaction id" do
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(response.response_code).to eq '001'
      expect(response.message).to eq 'Transaction Received'
    end
  end
end
