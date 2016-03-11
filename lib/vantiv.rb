require 'json'
require 'net/http'
require 'vantiv/api'
require 'vantiv/paypage'

module Vantiv
  def self.tokenize(temporary_token:)
    if temporary_token == "" or temporary_token == nil
      raise ArgumentError.new("Blank temporary token (PaypageRegistrationID): \n
                               Check that paypage error handling is implemented correctly.")
    end
    body = Api::TokenizationRequestBody.generate(
      paypage_registration_id: temporary_token
    )
    Api::Request.new(
      endpoint: Api::Endpoints::TOKENIZATION,
      body: body,
      response_class: Api::TokenizationResponse
    ).run
  end

  def self.auth(amount:, payment_account_id:, customer_id:, order_id:)
    body = Api::AuthRequestBody.generate(
      amount: amount,
      customer_id: customer_id,
      payment_account_id: payment_account_id,
      order_id: order_id
    )
    Api::Request.new(
      endpoint: Api::Endpoints::AUTHORIZATION,
      body: body,
      response_class: Api::AuthorizationResponse
    ).run
  end

  def self.auth_reversal(body)
    Api::Request.new(
      endpoint: Api::Endpoints::AUTH_REVERSAL,
      body: body
    ).run
  end

  def self.capture(body)
    Api::Request.new(
      endpoint: Api::Endpoints::CAPTURE,
      body: body
    ).run
  end

  def self.auth_capture(amount:, payment_account_id:, customer_id:, order_id:)
    body = Api::SaleRequestBody.generate(
      amount: amount,
      customer_id: customer_id,
      payment_account_id: payment_account_id,
      order_id: order_id
    )
    Api::Request.new(
      endpoint: Api::Endpoints::SALE,
      body: body,
      response_class: Api::SaleResponse
    ).run
  end

  # NOTE: ActiveMerchant's #refund... only for use on a capture or sale it seems
  #       -> 'returns' are refunds too, credits are tied to a sale/capture, returns can be willy nilly
  def self.credit(body)
    Api::Request.new(
      endpoint: Api::Endpoints::CREDIT,
      body: body
    ).run
  end

  def self.return(body)
    Api::Request.new(
      endpoint: Api::Endpoints::RETURN,
      body: body
    ).run
  end

  # NOTE: can void credits
  def self.void(body)
    Api::Request.new(
      endpoint: Api::Endpoints::VOID,
      body: body
    ).run
  end

  def self.configure
    yield self
  end

  class << self
    [:license_id, :acceptor_id, :application_id, :default_report_group, :order_source, :paypage_id].each do |config_var|
      define_method :"#{config_var}" do
        value = instance_variable_get(:"@#{config_var}")
        raise "Missing Vantiv configuration: #{config_var}" unless value
        value
      end

      define_method :"#{config_var}=" do |value|
        instance_variable_set(:"@#{config_var}", value)
      end
    end
  end

  def self.root
    File.dirname __dir__
  end
end
