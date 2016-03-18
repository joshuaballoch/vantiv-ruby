# Vantiv Ruby Client
[![Build Status](https://travis-ci.org/plated/vantiv-ruby.svg)](https://travis-ci.org/plated/vantiv-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vantiv-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vantiv-ruby

## Configuration

The gem needs the following configuration to be set on app initialization. It is highly recommended that you do not commit sensitive data into version control, but instead use environment variables.

```ruby
Vantiv.configure do |config|
  config.license_id = ENV["VANTIV_LICENSE_ID"]
  config.acceptor_id = ENV["VANTIV_ACCEPTOR_ID"]
  config.order_source = "desired-order-source"
  config.paypage_id = ENV["VANTIV_PAYPAGE_ID"]

  config.default_report_group = 'default-report-group'
end
```

## Certification

Vantiv's DevHub requires merchants to certify their applications for usage with their API. To make this integration process easy, the gem provides a script to run through these tests.

To certify your application, run the following script:

```
$ LICENSE_ID=sub-your-license-id-in-here ACCEPTOR_ID=sub-your-acceptor-id-in-here PAYPAGE_ID=your-paypage-id vantiv-certify-app
```

A certs.txt file will be generated in the directory that the script is run, and then opened. It contains a list of DevHub Certification test names and associated Request IDs, like follows:

```
L_AC_1, request-id-for-L_AC_1-here
L_AC_2, request-id-for-L_AC_2-here
```

Navigate to your application's page in DevHub's developer portal (apideveloper.vantiv.com). Paste the contents of this file into the validation form input field, and then click "Validate". 

## Usage

TODO: add usage notes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plated/vantiv-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

