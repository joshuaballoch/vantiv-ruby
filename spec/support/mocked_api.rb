module TestHelpers
  def error_message_for_mocked_api_failure(method_name:, expected_value:, got_value:, live_response:)
    "Expected ##{method_name} to return #{expected_value}, got #{got_value}\n
     Live response code: #{live_response.response_code}, msg: #{live_response.message}\n
     (Check that Cert API is not having stabilty issues)"
  end
end
