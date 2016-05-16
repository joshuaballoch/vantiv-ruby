# NOTE: This needs to exist to enable us to use PaymentAccountID's in specs
#       1. Vantiv has a list of accounts to use in the non-live environments, of various
#          account states, like valid accounts, accounts with insufficient funds, etc..
#       2. These accounts have specific card numbers, but we need to submit PaymentAccountID's,
#          not card data, on most transactions like auths and others.
#       3. They do NOT provide a list of PaymentAccountIDs with each of these test accounts. They
#          do not have a static list of them - they will be different in each merchant account
#          (with each different Acceptor ID).
#       4. Once the PaymentAccountID is requested, it does not change - so we get it, store it,
#          and read it in subsequent spec runs.
#
module Vantiv
  class TestAccount

    def self.valid_account
      fetch_account(
        card_number: "4457010000000009",
        expiry_month: "01",
        expiry_year: "16",
        cvv: "349"
      )
    end

    def self.insufficient_funds
      fetch_account(
        card_number: "4457010100000008",
        expiry_month: "06",
        expiry_year: "16",
        cvv: "992"
      )
    end

    def self.invalid_card_number
      new("4716605112879585", "01", "2020", "123")
    end

    def self.expired
      fetch_account(
        card_number: "5112001900000003",
        expiry_month: "01",
        expiry_year: "2020",
        cvv: "123"
      )
    end

    def self.invalid_account_number
      fetch_account(
        card_number: "5112010100000002",
        expiry_month: "07",
        expiry_year: "16",
        cvv: "251"
      )
    end

    def self.pick_up_card
      fetch_account(
        card_number: "375001010000003",
        expiry_month: "09",
        expiry_year: "16",
        cvv: "0421"
      )
    end

    def self.account_updater
      fetch_account(
        card_number: "4457000300000007",
        expiry_month: "01",
        expiry_year: "15",
        cvv: "123"
      )
    end

    def self.account_updater_account_closed
      fetch_account(
        card_number: "5112000101110009",
        expiry_month: "11",
        expiry_year: "99",
        cvv: "123"
      )
    end

    def self.account_updater_contact_cardholder
      fetch_account(
        card_number: "4457000301100004",
        expiry_month: "11",
        expiry_year: "99",
        cvv: "123"
      )
    end

    def self.fetch_account(card_number:, expiry_month:, expiry_year:, cvv:)
      acct = new(card_number, expiry_month, expiry_year, cvv)
      acct.read_or_get_data
      acct
    end

    attr_reader :card_number, :expiry_month, :expiry_year, :payment_account_id, :cvv

    def initialize(card_number, expiry_month, expiry_year, cvv)
      @card_number = card_number
      @expiry_month = expiry_month
      @expiry_year = expiry_year
      @cvv = cvv
    end

    def read_or_get_data
      File.open("#{test_accounts_directory}/#{card_number}", "a+") do |file|
        @payment_account_id = file.read
        if payment_account_id == "" || payment_account_id == nil
          @payment_account_id = request_payment_account_id
          file << payment_account_id
        end
      end
      raise "PaymentAccountID not found" unless payment_account_id
    end

    private

    def ensure_directory_exists
      dir = "#{Vantiv.root}/tmp/test_accounts"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      dir
    end

    def test_accounts_directory
      @test_accounts_directory ||= ensure_directory_exists
    end

    def tokenization_request_body
      Api::RequestBodyGenerator.run({
        "Transaction" => {
          "CustomerID" => "123"
        },
        "Card" => {
          "AccountNumber" => card_number,
          "ExpirationMonth" => expiry_month,
          "ExpirationYear" => expiry_year
        }
      })
    end

    def request_payment_account_id
      response = Api::Request.new(
        endpoint: "payment/sp2/services/v1/paymentAccountCreate",
        body: tokenization_request_body,
        response_object: Api::Response.new
      ).run
      raise "Tokenization Request not 200 OK, it's #{response.http_response_code}\n Response: #{response.body}" unless response.httpok
      response.body["litleOnlineResponse"]["registerTokenResponse"]["PaymentAccountID"]
    end
  end
end
