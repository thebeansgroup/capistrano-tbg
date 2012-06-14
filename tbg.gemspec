# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tbg/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vincent Siebert"]
  gem.email         = ["vincent@siebert.im"]
  gem.description   = %q{TBG deploy gem}
  gem.summary       = %q{DRYing the TBG deploy process}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "capistrano-tbg"
  # gem.require_paths = ["lib"]
  gem.version       = Capistrano::Tbg::VERSION
end
