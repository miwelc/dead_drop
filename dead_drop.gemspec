$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dead_drop/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dead_drop"
  s.version     = DeadDrop::VERSION
  s.authors     = ["Miguel Canton Cortes"]
  s.email       = ["miwelc@gmail.com"]
  s.homepage    = "https://github.com/miwelc/dead_drop"
  s.summary     = "Serving & controlling access to content in anonymous lockers"
  s.description = "DeadDrop allows you to drop content in an anonymous locker only accessible "+
                  "with a randomly generated token.\n"+
                  "You can configure when the content should expire and limit the number of "+
                  "total accesses to the content."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_development_dependency "activerecord-jdbcsqlite3-adapter" if RUBY_PLATFORM == 'java'
  s.add_development_dependency "sqlite3" unless RUBY_PLATFORM == 'java'
end
