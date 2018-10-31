$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "openid_auth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openid_auth"
  s.version     = OpenidAuth::VERSION
  s.authors     = ["Michael Bastos"]
  s.email       = ["bastosmichael@gmail.com"]
  s.homepage    = "https://api.vets.gov/services/auth/docs/v0"
  s.summary     = "OpenID Auth"
  s.description = "OpenID Auth API"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_development_dependency 'rspec-rails'
end
