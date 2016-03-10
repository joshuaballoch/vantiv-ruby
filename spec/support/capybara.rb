Capybara.register_driver :poltergeist do |app|
   options = {
      :js_errors => true ,
      :timeout => 120,
      :debug => false,
      :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
      :inspector => true,
   }
   Capybara::Poltergeist::Driver.new(app, options)
end


Capybara.configure do |config|
  config.default_max_wait_time = 20
  config.run_server = false
  config.default_driver = :poltergeist
end
