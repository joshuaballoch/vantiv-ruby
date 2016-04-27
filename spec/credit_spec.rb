require 'spec_helper'

describe "processing credits (refunds) on prior transactions" do
  let(:test_account) { Vantiv::TestAccount.valid_account }
  let(:payment_account_id) { test_account.payment_account_id }
  let(:customer_id) { "cust-id-123" }
  let(:order_id) { "order-#{rand(10000)}" }

  def run_credit
    Vantiv.credit(
      amount: @amount,
      transaction_id: prior_transaction.transaction_id
    )
  end

  context "on a prior auth and then capture transaction" do
    let(:prior_transaction) do
      auth_response = Vantiv.auth(
        amount: 14100,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
      Vantiv.capture(transaction_id: auth_response.transaction_id)
    end

    it "returns success when transaction is received" do
      expect(run_credit.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_credit
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_credit.response_code).to eq '001'
      expect(run_credit.message).to eq 'Transaction Received'
    end

    # TODO: check that this indeed works!! API txn received is no assurance at all..
    it "optionally accepts an amount for partial crediting" do
      @amount = 8000
      expect(run_credit.success?).to eq true
    end
  end

  context "on a prior auth_capture (sale) transaction" do
    let(:prior_transaction) do
      Vantiv.auth_capture(
        amount: 14100,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id,
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year
      )
    end

    it "returns success when transaction is received" do
      expect(run_credit.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_credit
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_credit.response_code).to eq '001'
      expect(run_credit.message).to eq 'Transaction Received'
    end

    # TODO: check that this indeed works!! API txn received is no assurance at all..
    it "optionally accepts an amount for partial crediting" do
      @amount = 8000
      expect(run_credit.success?).to eq true
    end
  end
end
