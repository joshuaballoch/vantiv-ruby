require 'spec_helper'

describe Vantiv::Api::RequestBody do
  describe ".for_direct_post_tokenization" do
    let(:card_number) { 1234 }
    let(:expiry_month) { 10 }
    let(:expiry_year) { 2018 }
    let(:cvv) { 222 }

    subject(:request_body) do
      Vantiv::Api::RequestBody.for_direct_post_tokenization(
        card_number: card_number,
        expiry_month: expiry_month,
        expiry_year: expiry_year,
        cvv: cvv
      )
    end

    it "includes stringified versions of card params" do
      expect(request_body["Card"]["AccountNumber"]).to eq(card_number.to_s)
      expect(request_body["Card"]["ExpirationMonth"]).to eq(expiry_month.to_s)
      expect(request_body["Card"]["ExpirationYear"]).to eq(expiry_year.to_s)
      expect(request_body["Card"]["CVV"]).to eq(cvv.to_s)
    end
  end

  describe ".for_tokenization" do
    subject(:request_body) do
      Vantiv::Api::RequestBody.for_tokenization(
        paypage_registration_id: @paypage_registration_id
      )
    end

    before do
      @paypage_registration_id = "some-temp-token"
    end

    it "includes the paypage registration ID correctly" do
      expect(request_body["Card"]["PaypageRegistrationID"]).to eq "some-temp-token"
    end
  end

  describe ".for_capture" do
    subject(:request_body) do
      Vantiv::Api::RequestBody.for_capture(
        amount: @amount,
        transaction_id: "transactionid123"
      )
    end

    it "includes the transaction id" do
      @amount = nil
      expect(request_body["Transaction"]).to eq(
        {
          "TransactionID" => "transactionid123"
        }
      )
    end

    it "can include a transaction amount" do
      @amount = 58888
      expect(request_body["Transaction"]).to eq(
        {
          "TransactionID" => "transactionid123",
          "TransactionAmount" => "588.88"
        }
      )
    end
  end

  describe ".for_auth_or_sale" do
    subject(:request_body) do
      Vantiv::Api::RequestBody.for_auth_or_sale(
        amount: 4224,
        customer_id: "extid123",
        payment_account_id: "paymentacct123",
        order_id: "SomeOrder123"
      )
    end

    it "includes a Transaction object" do
      expect(request_body["Transaction"]).not_to eq nil
    end

    it "includes the PaymentAccountID" do
      expect(request_body["PaymentAccount"]["PaymentAccountID"]).to eq "paymentacct123"
    end
  end

  describe ".transaction_element" do
    def transaction_element
      Vantiv::Api::RequestBody.transaction_element(
        amount: @amount,
        customer_id: "some-cust",
        order_id: "some-order"
      )
    end

    before do
      @amount = 4
    end

    it "formats the amount (in cents) as dollar 2 decimal format" do
      @amount = 4224
      expect(transaction_element["Transaction"]["TransactionAmount"]).to eq "42.24"
      @amount = 424
      expect(transaction_element["Transaction"]["TransactionAmount"]).to eq "4.24"
      @amount = 881424
      expect(transaction_element["Transaction"]["TransactionAmount"]).to eq "8814.24"
    end

    it "includes a customer ID (required by Vantiv)" do
      expect(transaction_element["Transaction"]["CustomerID"]).to eq "some-cust"
    end

    it "includes the default order source" do
      expect(transaction_element["Transaction"]["OrderSource"]).to eq "ecommerce"
    end

    it "includes the merchant reference number for the order (required by Vantiv)" do
      expect(transaction_element["Transaction"]["ReferenceNumber"]).to eq "some-order"
    end
  end
end
