require 'json'
require 'net/http'
require 'vantiv/api'

module Vantiv
  def self.auth(body)
    Api::Request.new(
      endpoint: Api::Endpoints::AUTHORIZATION,
      body: body
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

  # NOTE: ActiveMerchant's #auth_capture... what naming should we use here?
  def self.sale(body)
    Api::Request.new(
      endpoint: Api::Endpoints::SALE,
      body: body
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
    attr_accessor :license_id, :acceptor_id, :application_id, :default_report_group
  end

  def self.root
    File.dirname __dir__
  end
end
