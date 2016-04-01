module Vantiv
  class TestCard
    class CardNotFound < StandardError; end
    CARDS = [
      {
        access_method_name: "valid_account",
        attrs: {
          card_number: "4457010000000009",
          expiry_month: "01",
          expiry_year: "16",
          cvv: "349",
          mocked_sandbox_payment_account_id: "1111111111110009",
          network: "VI"
        }
      },
      {
        access_method_name: "invalid_card_number",
        attrs: {
          card_number: "4457010010900010",
          expiry_month: "01",
          expiry_year: "16",
          cvv: "349",
          mocked_sandbox_payment_account_id: nil,
          network: "VI"
        }
      },
      {
        access_method_name: "invalid_account_number",
        attrs: {
          card_number: "5112001600000006",
          expiry_month: "01",
          expiry_year: "20",
          cvv: "349",
          mocked_sandbox_payment_account_id: "1111111111130006",
          network: "MC"
        }
      },
      {
        access_method_name: "insufficient_funds",
        attrs: {
          card_number: "4457002100000005",
          expiry_month: "01",
          expiry_year: "20",
          cvv: "349",
          mocked_sandbox_payment_account_id: "1111111111120005",
          network: "VI"
        }
      },
      {
        access_method_name: "expired_card",
        attrs: {
          card_number: "5112001900000003",
          expiry_month: "01",
          expiry_year: "20",
          cvv: "349",
          mocked_sandbox_payment_account_id: "1111111111140003",
          network: "MC"
        }
      }
    ]

    def self.all
      CARDS.map do |raw_card|
        new(raw_card[:attrs].merge(name: raw_card[:access_method_name]))
      end
    end

    CARDS.each do |raw_card|
      define_singleton_method :"#{raw_card[:access_method_name]}" do
        new(raw_card[:attrs].merge(name: raw_card[:access_method_name]))
      end
    end

    def self.find(card_number)
      card = CARDS.find do |card_data|
        card_data[:attrs][:card_number] == card_number
      end
      raise CardNotFound.new("No card with account number #{card_number}") unless card
      new(card[:attrs])
    end

    attr_reader :card_number, :expiry_month, :expiry_year, :cvv, :mocked_sandbox_payment_account_id, :network, :name

    def initialize(card_number:, expiry_month:, expiry_year:, cvv:, mocked_sandbox_payment_account_id:, network:, name:)
      @card_number = card_number
      @expiry_month = expiry_month
      @expiry_year = expiry_year
      @cvv = cvv
      @mocked_sandbox_payment_account_id = mocked_sandbox_payment_account_id
      @network = network
      @name = name
    end
  end
end
