module Vantiv
  class TestPaypageDriver

    def start
      test_paypage_server.start
      start_driver
    end

    def stop
      test_paypage_server.stop
      driver.quit
    end

    def get_paypage_registration_id(card_number)
      driver.navigate.to test_paypage_server.root_path

      driver.switch_to.frame('vantiv-payframe')
      driver.find_element(:id, 'accountNumber').send_keys card_number
      driver.find_element(:id, 'cvv').send_keys '123'

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

    def test_paypage_server
      @test_paypage_server ||= Vantiv::TestPaypageServer.new
    end

  end
end
