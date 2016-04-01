require 'spec_helper'

describe "directly tokenizing card data" do
  let(:response) do
    Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    )
  end

  context "with a valid account number" do
    let(:card) { Vantiv::TestAccount.valid_account }

    it "returns success" do
      expect(response.success?).to eq true
    end

    it "returns a payment account id" do
      expect(response.payment_account_id).not_to eq nil
      expect(response.payment_account_id).not_to eq ""
    end

    it "enables using the payment account id for subsequent transactions" do
      payment_account_id = response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah"
      )
      expect(auth_response.success?).to eq true
    end

    it "returns an 802 response code" do
      expect(response.response_code).to eq('802')
    end
  end

  context "when the credit card number is completely invalid" do
    let(:card) { Vantiv::TestAccount.invalid_card_number }

    it "returns failure" do
      expect(response.success?).to eq false
      expect(response.failure?).to eq true
    end

    it "does not return a payment account id" do
      expect(response.payment_account_id).to eq nil
    end

    it "reveals that the card number was invalid" do
      expect(response.invalid_card_number?).to eq true
    end

    it "returns a human readable message" do
      expect(response.message).to match(/credit card number was invalid/i)
    end

    it "returns an 820 response code" do
      expect(response.response_code).to eq('820')
    end
  end

  context "when the credit card is expired" do
    let(:card) { Vantiv::TestAccount.expired }

    it "returns success" do
      expect(response.success?).to eq true
    end

    it "returns a payment account id" do
      expect(response.payment_account_id).not_to eq nil
      expect(response.payment_account_id).not_to eq ""
    end

    it "only reveals account expired issue on subsequent transactions" do
      payment_account_id = response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah"
      )
      expect(auth_response.success?).to eq false
      expect(auth_response.expired_card?).to eq true
    end

    it "returns an 802 response code" do
      expect(response.response_code).to eq('802')
    end
  end

  context "with an account with an invalid account number" do
    let(:card) { Vantiv::TestAccount.invalid_account_number }

    it "returns success" do
      expect(response.success?).to eq true
    end

    it "returns a payment account id" do
      expect(response.payment_account_id).not_to eq nil
      expect(response.payment_account_id).not_to eq ""
    end

    it "only reveals account validity issue on subsequent transactions" do
      payment_account_id = response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah"
      )
      expect(auth_response.success?).to eq false
      expect(auth_response.invalid_account_number?).to eq true
    end

    it "returns an 802 response code" do
      expect(response.response_code).to eq('802')
    end
  end
end
