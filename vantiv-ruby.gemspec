Gem::Specification.new do |s|
  s.name        = 'vantiv-ruby'
  s.version     = '0.0.0'
  s.date        = '2016-02-24'
  s.summary     = "Ruby client for Vantiv's DevHub API"
  s.description = "A simple hello world gem"
  s.authors     = ["Josh Balloch"]
  s.email       = 'joshuaballoch@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://wwww.plated.com/edit-this-url'
  s.license     = 'edit this too'

  s.executables << 'vantiv-certify-app'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'dotenv'
  s.add_development_dependency 'pry'
end
