require 'spec_helper'

describe Vantiv::Api::Response do
  let(:httpok) { true }
  let(:transaction_response_name) { "responseName" }
  let(:response) do
    response = Vantiv::Api::Response.new
    response.load(
      httpok: httpok,
      http_response_code: "1234",
      body: body
    )
    response
  end

  def body_with_params(params)
    {
      "litleOnlineResponse" => {
        "@message" => "this is a message"
      }.merge(params)
    }
  end

  def set_transaction_response_name
    response.instance_variable_set(
      :@transaction_response_name,
      transaction_response_name
    )
  end

  describe "#request_id" do
    let(:request_id) { "request id" }
    let(:body) do
      {
        "RequestID" => request_id
      }
    end

    it "returns the response body's request id" do
      expect(response.request_id).to eq(request_id)
    end
  end

  describe "api_level_failure?" do

    context "when the http response code is not ok" do
      let(:httpok) { false }
      let(:body) { {} }

      it "is true" do
        expect(response.api_level_failure?).to eq(true)
      end
    end

    context "when there is an error message present" do
      let(:body) { body_with_params({"@message" => "error"}) }

      it "is true" do
        expect(response.api_level_failure?).to eq(true)
      end
    end

    context "with an ok http response and no error message" do
      let(:body) { body_with_params({ "@message" => "message" }) }

      it "is false" do
        expect(response.api_level_failure?).to eq(false)
      end
    end
  end

  describe "#message" do
    let(:message) { "some message" }
    let(:body) do
      body_with_params({
        transaction_response_name => {
          "message" => message
        }
      })
    end

    it "returns the litle transaction response's message" do
      set_transaction_response_name
      expect(response.message).to eq(message)
    end
  end

  describe "#response_code" do
    let(:code) { "some code" }
    let(:body) do
      body_with_params({
        transaction_response_name => {
          "response" => code
        }
      })
    end

    it "returns the litle transaction response's code" do
      set_transaction_response_name
      expect(response.response_code).to eq(code)
    end
  end

  describe "#transaction_id" do
    let(:transaction_id) { "some transaction_id" }
    let(:body) do
      body_with_params({
        transaction_response_name => {
          "TransactionID" => transaction_id
        }
      })
    end

    it "returns the litle transaction response's transaction id" do
      set_transaction_response_name
      expect(response.transaction_id).to eq(transaction_id)
    end
  end

  describe "#error_message" do
    context "when configuration leads to API level failure" do
      let(:api_error_message) { "error message" }
      let(:httpok) { false }
      let(:body) do
        {
          "errorcode"=>"400",
          "errormsg"=> api_error_message,
          "errortype"=>"sender",
          "correlationid"=>"b9c1f38b-0fb8-416c-deef-3eb7288634ee"
        }
       end

      it "returns the given error message" do
        expect(response.error_message).to eq(api_error_message)
      end
    end

    context "with a non api-level failure" do
      let(:httpok) { true }
      let(:non_api_error_message) { "other error message" }
      let(:body) do
        body_with_params({
          transaction_response_name => {
            "message" => non_api_error_message
          }
        })
      end

      it "returns the litle transaction's  message" do
        set_transaction_response_name
        expect(response.error_message).to eq(non_api_error_message)
      end
    end
  end
end
