require 'spec_helper'

describe Vantiv::Api::RequestBodyGenerator do

  it "merges any number of parts into a full request body" do
    hash1 = {
      "Transaction" => {
        "Blah" => "5"
      }
    }
    hash2 = {
      "PaymentAccount" => {
        "PaymentAccountID" => "q2"
      }
    }
    allow(SecureRandom).to receive(:hex) { "random-hex" }

    body = Vantiv::Api::RequestBodyGenerator.run(hash1, hash2)
    expect(body).to eq(
      {
        "Credentials" => {
          "AcceptorID" => Vantiv.acceptor_id
        },
        "Reports" => {
          # NOTE: this is required by vantiv, so a default is left here.
          #       If a user wants to use this Vantiv feature, it can be made dynamic.
          "ReportGroup" => Vantiv.default_report_group
        },
        "Application" => {
          "ApplicationID" => "random-hex"
        },
        "Transaction" => {
          "Blah" => "5"
        },
        "PaymentAccount" => {
          "PaymentAccountID" => "q2"
        }
      }
    )
  end

  it "creates a new application id each time" do
    body_1 = Vantiv::Api::RequestBodyGenerator.run({})
    body_2 = Vantiv::Api::RequestBodyGenerator.run({})
    expect(body_1["Application"]["ApplicationID"]).not_to eq(
      body_2["Application"]["ApplicationID"]
    )
  end
end
