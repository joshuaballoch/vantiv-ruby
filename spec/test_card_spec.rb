require 'spec_helper'

describe Vantiv::TestCard do

  describe ".find" do
    it "returns the correct card" do
      expect(Vantiv::TestCard.find("5112001900000003")).to eq Vantiv::TestCard.expired_card
    end

    it "warns if it can't find the card" do
      expect{
        Vantiv::TestCard.find("1234")
      }.to raise_error(/no card/i)
    end
  end

  describe ".find_by_payment_account_id" do
    it "returns the correct card" do
      expect(
        Vantiv::TestCard.find_by_payment_account_id(
          Vantiv::TestCard.expired_card.mocked_sandbox_payment_account_id
        )
      ).to eq Vantiv::TestCard.expired_card
    end

    it "warns if it can't find the card" do
      expect{
        Vantiv::TestCard.find_by_payment_account_id("1234")
      }.to raise_error(/no card/i)
    end
  end

  it "can be compared to itself" do
    expect(Vantiv::TestCard.invalid_card_number == Vantiv::TestCard.invalid_card_number).to eq true
    expect(Vantiv::TestCard.invalid_card_number != Vantiv::TestCard.invalid_card_number).to eq false
  end

  it "can be compared to other cards" do
    expect(Vantiv::TestCard.invalid_card_number == Vantiv::TestCard.expired_card).to eq false
    expect(Vantiv::TestCard.invalid_card_number != Vantiv::TestCard.expired_card).to eq true
  end
end
