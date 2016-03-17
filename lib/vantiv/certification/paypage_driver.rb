require "vantiv/certification/paypage_server"
require "selenium-webdriver"

module Vantiv
  module Certification
    class PaypageDriver

      def start
        paypage_server.start
        start_driver
        self
      end

      def stop
        paypage_server.stop
        driver.quit
      end

      def get_paypage_registration_id(card_number, cvv = '123')
        driver.navigate.to paypage_server.root_path

        driver.switch_to.frame('vantiv-payframe')
        driver.find_element(:id, 'accountNumber').send_keys card_number
        driver.find_element(:id, 'cvv').send_keys cvv

        driver.switch_to.default_content
        button = driver.find_element(:id, 'submit')
        button.click

        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until {
          driver.find_element(:id, "request-status").text.include?("Request Complete")
        }

        driver.find_element(:id, 'temp-token').text
      end

      private

      def start_driver
        driver.manage.timeouts.implicit_wait = 10
      end

      def driver
        @driver ||= Selenium::WebDriver.for :phantomjs
      end

      def paypage_server
        @paypage_server ||= Vantiv::Certification::PaypageServer.new
      end

    end
  end
end
