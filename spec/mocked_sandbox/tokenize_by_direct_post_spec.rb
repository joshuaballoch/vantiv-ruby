require 'spec_helper'
include TestHelpers

describe "mocked API requests to tokenize_by_direct_post" do
  def run_mocked_response
    Vantiv::MockedSandbox.enable_self_mocked_requests!
    response = Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    )
    Vantiv::MockedSandbox.disable_self_mocked_requests!
    response
  end

  let(:mocked_response) { run_mocked_response }
  let(:live_response) do
    Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    )
  end

  after { Vantiv::MockedSandbox.disable_self_mocked_requests! }

  Vantiv::TestCard.all.each do |test_card|
    let(:card) { test_card }

    context "with a #{test_card.name}" do
      it "the mocked response's public methods return the same as the live one" do
      (
        Vantiv::Api::TokenizationResponse.instance_methods(false) +
        Vantiv::Api::Response.instance_methods(false) -
        [:payment_account_id, :body, :load, :request_id, :transaction_id]
      ).each do |method_name|
          live_response_value = live_response.send(method_name)
          mocked_response_value = mocked_response.send(method_name)

          expect(mocked_response_value).to eq(live_response_value),
            error_message_for_mocked_api_failure(
              method_name: method_name,
              expected_value: live_response_value,
              got_value: mocked_response_value,
              live_response: live_response
            )
        end
      end

      it "returns the whitelisted payment account id" do
        expect(mocked_response.success?).to eq true
        expect(mocked_response.payment_account_id).to eq card.mocked_sandbox_payment_account_id
      end

      it "returns a dynamic transaction id" do
        response_1 = run_mocked_response
        response_2 = run_mocked_response
        expect(response_1.transaction_id).not_to eq response_2.transaction_id
      end
    end
  end
end
