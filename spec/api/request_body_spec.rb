require 'spec_helper'

describe Vantiv::Api::RequestBody do

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

  describe ".transaction_object" do
    def transaction_object
      Vantiv::Api::RequestBody.transaction_object(
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
      expect(transaction_object["Transaction"]["TransactionAmount"]).to eq "42.24"
      @amount = 424
      expect(transaction_object["Transaction"]["TransactionAmount"]).to eq "4.24"
      @amount = 881424
      expect(transaction_object["Transaction"]["TransactionAmount"]).to eq "8814.24"
    end

    it "includes a customer ID (required by Vantiv)" do
      expect(transaction_object["Transaction"]["CustomerID"]).to eq "some-cust"
    end

    it "includes the default order source" do
      expect(transaction_object["Transaction"]["OrderSource"]).to eq "ecommerce"
    end

    it "includes the merchant reference number for the order (required by Vantiv)" do
      expect(transaction_object["Transaction"]["ReferenceNumber"]).to eq "some-order"
    end
  end
end
