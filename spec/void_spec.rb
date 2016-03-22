require 'spec_helper'

describe "processing voids" do
  let(:payment_account_id) { Vantiv::TestAccount.valid_account.payment_account_id }
  let(:customer_id) { "customer-#{rand(10000)}" }
  let(:order_id) { "order-#{rand(10000)}" }

  def run_void
    Vantiv.void(transaction_id: prior_transaction.transaction_id)
  end

  context "on prior same-day captures" do
    let(:prior_transaction) do
      auth = Vantiv.auth(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id
      )
      Vantiv.capture(transaction_id: auth.transaction_id)
    end

    it "returns success when transaction is received" do
      expect(run_void.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_void
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_void.response_code).to eq '001'
      expect(run_void.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day credits" do
    let(:prior_transaction) do
      sale = Vantiv.auth_capture(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id
      )
      Vantiv.credit(transaction_id: sale.transaction_id)
    end

    it "returns success when transaction is received" do
      expect(run_void.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_void
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_void.response_code).to eq '001'
      expect(run_void.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day auth_capture (sale) transactions" do
    let(:prior_transaction) do
      Vantiv.auth_capture(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id
      )
    end

    it "returns success when transaction is received" do
      expect(run_void.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_void
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_void.response_code).to eq '001'
      expect(run_void.message).to eq 'Transaction Received'
    end
  end

  context "on prior same-day refunds" do
    let(:prior_transaction) do
      Vantiv.return(
        amount: 81800,
        customer_id: customer_id,
        order_id: order_id,
        payment_account_id: payment_account_id
      )
    end

    it "returns success when transaction is received" do
      expect(run_void.success?).to eq true
    end

    it "returns a new transaction id" do
      response = run_void
      expect(response.transaction_id).not_to eq nil
      expect(response.transaction_id).not_to eq ""
    end

    it "returns a 001 transaction received response code" do
      expect(run_void.response_code).to eq '001'
      expect(run_void.message).to eq 'Transaction Received'
    end
  end
end
