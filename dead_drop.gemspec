$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dead_drop/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dead_drop"
  s.version     = DeadDrop::VERSION
  s.authors     = ["Miguel Canton Cortes"]
  s.email       = ["miwelc@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of DeadDrop."
  s.description = "TODO: Description of DeadDrop."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
end
