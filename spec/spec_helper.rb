RSpec.configure do |config|
  require 'vantiv-ruby'
  require 'dotenv'
  Dotenv.load

  Vantiv.configure do |config|
    config.license_id = ENV["LICENSE_ID"]
    config.acceptor_id = ENV["ACCEPTOR_ID"]
    config.application_id = ENV["APP_ID"]

    config.default_report_group = '1'
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
