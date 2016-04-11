require 'spec_helper'

describe Vantiv::MockedSandbox::ApiRequest do
  let(:card) do
    Vantiv::TestCard.new(
      card_number: "4581537455985878",
      expiry_month: "08",
      expiry_year: "18",
      mocked_sandbox_payment_account_id: nil,
      network: nil,
      cvv: "123",
      name: "bobbybil"
    )
  end

  let(:run_mocked_request) {
    Vantiv::MockedSandbox::ApiRequest.run(
      endpoint: Vantiv::Api::Endpoints::TOKENIZATION,
      body: Vantiv::Api::RequestBody.for_direct_post_tokenization(
        card_number: card.card_number,
        expiry_month: card.expiry_month,
        expiry_year: card.expiry_year,
        cvv: card.cvv
      ).to_json
    )
  }

  it "raises an error showing the user that the card is not whitelisted" do
    expect{
      run_mocked_request
    }.to raise_error(/Fixture not found/)
  end
end
