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

  let(:body) do
    Vantiv::Api::RequestBody.for_direct_post_tokenization(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    ).to_json
  end

  let(:run_mocked_request) {
    Vantiv::MockedSandbox::ApiRequest.run(
      endpoint: Vantiv::Api::Endpoints::TOKENIZATION,
      body: body
    )
  }

  it "raises an error showing the user that the card is not whitelisted" do
    expect{
      run_mocked_request
    }.to raise_error(/Fixture not found/)
  end

  context "when to_json is overridden (rails...)" do
    let(:card) { Vantiv::TestCard.valid_account }

    before do
      body
      allow_any_instance_of(Hash).to receive(:to_json)
        .and_return({ something: "bad" })
    end

    it "returns the correct response body" do
      response_body = run_mocked_request[:body]
      expect(response_body["litleOnlineResponse"]).to be
      expect(response_body[:something]).to be_nil
    end
  end
end
