require 'spec_helper'

describe Vantiv::Api::AuthRequestBody do
  subject(:request_body) do
    Vantiv::Api::AuthRequestBody.generate(
      amount: 4224,
      customer_id: "extid123",
      payment_account_id: "paymentacct123",
      order_id: "SomeOrder123"
    )
  end

  it "formats the amount (in cents) as dollar 2 decimal format" do
    expect(request_body["Transaction"]["TransactionAmount"]).to eq "42.24"
  end

  it "includes a customer ID (required by Vantiv)" do
    expect(request_body["Transaction"]["CustomerID"]).to eq "extid123"
  end

  it "includes the default order source" do
    expect(request_body["Transaction"]["OrderSource"]).to eq "ecommerce"
  end

  it "includes the merchant reference number for the order (required by Vantiv)" do
    expect(request_body["Transaction"]["ReferenceNumber"]).to eq "SomeOrder123"
  end

  it "includes the PaymentAccountID" do
    expect(request_body["PaymentAccount"]["PaymentAccountID"]).to eq "paymentacct123"
  end
end
