require 'spec_helper'

describe "toggling mocked API requests" do
  let(:card) { Vantiv::TestCard.valid_account }

  def response
    Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv
    )
  end

  it "does not continue mocking if environment changed to non-mocked environment" do
    Vantiv::MockedSandbox.enable_self_mocked_requests!
    mocked_payment_account_id = response.payment_account_id

    Vantiv::MockedSandbox.disable_self_mocked_requests!
    non_mocked_payment_account_id = response.payment_account_id

    expect(non_mocked_payment_account_id).not_to eq mocked_payment_account_id

    Vantiv::MockedSandbox.disable_self_mocked_requests!
  end

  it "is idempotently mocking when the environment changes" do
    2.times do
      Vantiv::MockedSandbox.enable_self_mocked_requests!
    end
    mocked_payment_account_id = response.payment_account_id
    Vantiv::MockedSandbox.disable_self_mocked_requests!
    non_mocked_payment_account_id = response.payment_account_id
    expect(non_mocked_payment_account_id).not_to eq mocked_payment_account_id
  end

  it "prevents mocking in production" do
    Vantiv.configure do |config|
      config.environment = Vantiv::Environment::PRODUCTION
    end
    expect{
      Vantiv::MockedSandbox.enable_self_mocked_requests!
    }.to raise_error(/cannot mock in production/)
    expect(Vantiv::MockedSandbox::ApiRequest).to_not receive :run
    response
    Vantiv.configure do |config|
      config.environment = Vantiv::Environment::CERTIFICATION
    end
  end
end
