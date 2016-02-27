module Vantiv
  module Api
    module Endpoints
      class Base < Struct.new(:url, :response_class)
      end
      AUTHORIZATION = Base.new(
        "payment/sp2/credit/v1/authorization",
        Vantiv::Api::AuthorizationResponse
      )
      CAPTURE = Base.new(
        "payment/sp2/credit/v1/authorizationCompletion",
        Vantiv::Api::Response
      )
      AUTH_REVERSAL = Base.new(
        "payment/sp2/credit/v1/reversal",
        Vantiv::Api::Response
      )
      SALE = Base.new(
        "payment/sp2/credit/v1/sale",
        Vantiv::Api::Response
      )
      CREDIT = Base.new(
        "payment/sp2/credit/v1/credit",
        Vantiv::Api::Response
      )
      RETURN = Base.new(
        "payment/sp2/credit/v1/return",
        Vantiv::Api::Response
      )
      VOID = Base.new(
        "payment/sp2/credit/v1/void",
        Vantiv::Api::Response
      )
    end
  end
end

