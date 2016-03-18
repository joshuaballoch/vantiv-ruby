require 'spec_helper'

describe "capturing authorizations" do
  let(:payment_account_id) { Vantiv::TestAccount.valid_account.payment_account_id }
  let(:transaction_id) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: "Anything-#{rand(10000)}",
      order_id: "AnyOrder#{rand(100000)}"
    ).transaction_id
  end

  let(:amount) { nil }

  def run_capture
    Vantiv.capture(
      transaction_id: transaction_id,
      amount: amount
    )
  end

  it "returns success when transaction is received" do
    expect(run_capture.success?).to eq true
  end

  it "returns a new transaction id" do
    response = run_capture
    expect(response.transaction_id).not_to eq nil
    expect(response.transaction_id).not_to eq ""
    expect(response.transaction_id).not_to eq transaction_id
  end

  it "returns a 001 transaction received response code" do
    expect(run_capture.response_code).to eq '001'
    expect(run_capture.message).to eq 'Transaction Received'
  end

  context "when nonexistent transaction is used" do
    let(:transaction_id) { "99997933698012190" }

    it "still returns 001 txn received" do
      response = run_capture
      expect(response.success?).to eq true
      expect(response.failure?).to eq false
      expect(response.response_code).to eq '001'
    end
  end

  context "when capturing a specific amount of the authorization" do
    let(:amount) { 1000 }

    it "just returns 001 txn received, with no indication of success" do
      response = run_capture
      expect(response.success?).to eq true
      expect(response.failure?).to eq false
      expect(response.response_code).to eq '001'
    end
  end

  context "when capturing an amount exceeding the authorization" do
    let(:amount) { 20000 }

    it "still returns 001 txn received" do
      response = run_capture
      expect(response.success?).to eq true
      expect(response.failure?).to eq false
      expect(response.response_code).to eq '001'
    end
  end
end
