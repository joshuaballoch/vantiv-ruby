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
          "ApplicationID" => Vantiv.application_id
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
end
