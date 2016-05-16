require 'spec_helper'

describe "processing standalone refunds" do
  let(:test_account) { Vantiv::TestAccount.valid_account }
  let(:payment_account_id) { test_account.payment_account_id }
  let(:order_id) { "order-#{rand(10000)}" }

  subject(:response) do
    run_refund
  end

  def run_refund
    Vantiv.refund(
      amount: 10000,
      customer_id: "cust-id-123",
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

  context "duplicate transaction checking" do
    it "returns a new transaction id for each new return, even with same order and customer id" do
      return_1 = run_refund
      return_2 = run_refund
      expect(return_1.transaction_id).not_to eq return_2.transaction_id
    end
  end
end
