require 'spec_helper'

describe "mocked API requests to void" do
  let(:live_sandbox_payment_account_id) do
    Vantiv::TestAccount.fetch_account(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    ).payment_account_id
  end

  let(:customer_id) { "customer-#{rand(100)}" }
  let(:order_id) { "order-#{rand(100)}" }
  let(:amount) { 10100 }

  let(:mocked_auth_capture_transaction_id) do
    rand(10 ** 17)
  end

  let(:live_auth_capture_transaction_id) do
    Vantiv.auth_capture(
      amount: amount,
      payment_account_id: live_sandbox_payment_account_id,
      customer_id: customer_id,
      order_id: order_id
    ).transaction_id
  end

  def run_mocked_response
    Vantiv::MockedSandbox.enable_self_mocked_requests!
    response = Vantiv.void(
      transaction_id: mocked_auth_capture_transaction_id
    )
    Vantiv::MockedSandbox.disable_self_mocked_requests!
    response
  end

  let(:mocked_response) { run_mocked_response }
  let(:live_response) do
    Vantiv.void(
      transaction_id: live_auth_capture_transaction_id
    )
  end

  after { Vantiv::MockedSandbox.disable_self_mocked_requests! }

  Vantiv::TestCard.all.each do |test_card|
    next unless test_card.tokenizable?

    let(:card) { test_card }

    context "with a #{test_card.name}" do
      (
        Vantiv::Api::TiedTransactionResponse.instance_methods(false) +
        Vantiv::Api::Response.instance_methods(false) -
        [:payment_account_id, :body, :load, :request_id, :transaction_id]
      ).each do |method_name|
        it "the mocked response returns the same as the live one for ##{method_name}" do
          expect(mocked_response.send(method_name)).to eq live_response.send(method_name)
        end
      end

      it "returns a dynamic transaction id" do
        response_1 = run_mocked_response
        response_2 = run_mocked_response
        expect(response_1.transaction_id).not_to eq response_2.transaction_id
      end
    end
  end
end
