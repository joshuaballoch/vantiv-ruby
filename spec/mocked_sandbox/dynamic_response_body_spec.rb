require 'spec_helper'
require 'vantiv/mocked_sandbox/dynamic_response_body'

describe Vantiv::MockedSandbox::DynamicResponseBody do
  let(:static_body) do
    {
      "litleOnlineResponse" => {
        "@version" => "10.2",
        "@response" => "0",
        "@message" => "Valid Format",
        "makeMeDynamicResponse" => {
          "@id" => "d234a56a4589d3d865c6d1d5",
          "@reportGroup" => "1",
          "@customerId" => "not-dynamic-cust-id",
          "orderId" => "not-dynamic-order-id",
          "response" => "999",
          "responseTime" => "static-response-time",
          "postDate" => "static-post-date",
          "message" => "The raw message",
          "TransactionID" => "static-transaction-id"
        }
      },
      "RequestID" => "90ccde12-3b97-41b3-f8e5-bc3ed85ffdb1"
    }
  end

  let(:dynamic_response) do
    described_class.generate(
      body: static_body,
      litle_txn_name: "makeMeDynamicResponse",
      mocked_payment_account_id: @mocked_payment_account_id
    )
  end

  it "makes report group the default report group" do
    expect(
      dynamic_response["litleOnlineResponse"]["makeMeDynamicResponse"]["@reportGroup"]
    ).to eq "<%= Vantiv.default_report_group %>"
  end

  it "makes the response time dynamic" do
    expect(
      dynamic_response["litleOnlineResponse"]["makeMeDynamicResponse"]["responseTime"]
    ).to eq "<%= Time.now.strftime('%FT%T') %>"
  end

  it "makes the transaction ID dynamic" do
    expect(
      dynamic_response["litleOnlineResponse"]["makeMeDynamicResponse"]["TransactionID"]
    ).to eq "<%= rand(10**17) %>"
  end

  it "makes the payment account id dynamic if it exists" do
    @mocked_payment_account_id = "mocked-payment-account-id"
    static_body["litleOnlineResponse"]["makeMeDynamicResponse"]["PaymentAccountID"] = "cert-env-payment-account-id"
    expect(
      dynamic_response["litleOnlineResponse"]["makeMeDynamicResponse"]["PaymentAccountID"]
    ).to eq "mocked-payment-account-id"
  end

  it "makes the post date dynamic if it exists" do
    static_body["litleOnlineResponse"]["makeMeDynamicResponse"]["postDate"] = "static-post-date"
    expect(
      dynamic_response["litleOnlineResponse"]["makeMeDynamicResponse"]["postDate"]
    ).to eq "<%= Time.now.strftime('%F') %>"
  end
end
