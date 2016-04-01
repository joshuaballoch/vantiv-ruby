require 'vantiv/mocked_sandbox/api_request'

module Vantiv
  module MockedSandbox
    def self.enable_self_mocked_requests!
      raise "Usage Error: cannot mock in production" if Vantiv::Environment.production?

      unless Vantiv::Api::Request.instance_methods.include? :orig_run_request
        Vantiv::Api::Request.send(:alias_method, :orig_run_request, :run_request)
      end
      Vantiv::Api::Request.send(:define_method, :run_request) do
        Vantiv::MockedSandbox::ApiRequest.run(
          endpoint: endpoint,
          body: body
        )
      end
    end

    def self.disable_self_mocked_requests!
      if Vantiv::Api::Request.instance_methods.include? :orig_run_request
        Vantiv::Api::Request.send(:alias_method, :run_request, :orig_run_request)
      end
    end

    def self.fixtures_directory
      "#{Vantiv.root}/lib/vantiv/mocked_sandbox/fixtures/"
    end
  end
end
