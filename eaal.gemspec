# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eaal"
Gem::Specification.new do |s|
  s.name = "eaal"
  s.version = EAAL::VERSION 

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Petermann"]
  s.date = "2012-10-21"
  s.description = "EAAL (Eve API Access Layer) is a ruby library for accessing data of the API of\nthe game Eve Online"
  s.email = ["ppetermann80@googlemail.com"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/eaal.rb", "lib/eaal/api.rb", "lib/eaal/cache/base.rb", "lib/eaal/cache/file.rb", "lib/eaal/cache/memcached.rb", "lib/eaal/exception.rb", "lib/eaal/result.rb", "lib/eaal/rowset.rb", "test/fixtures/test/test/account/Characters/Request_.xml", "test/fixtures/test/test/char/CharacterSheet/Request_.xml", "test/fixtures/test/test/char/CharacterSheet/Request_characterID_12345.xml", "test/fixtures/test/test/char/Killlog/Request_.xml", "test/fixtures/test/test/char/Killlog/Request_characterID_12345.xml", "test/fixtures/test/test/char/SkillInTraining/Request_characterID_12345.xml", "test/fixtures/test/test/char/SkillQueue/Request_characterID_12345.xml", "test/fixtures/test/test/char/Standings/Request_.xml", "test/fixtures/test/test/char/Standings/Request_characterID_12345.xml", "test/fixtures/test/test/corp/CorporationSheet/Request_corporationID_150212025.xml", "test/fixtures/test/test/eve/AllianceList/Request_.xml", "test/fixtures/test/test/server/ServerStatus/Request_.xml", "test/test_eaal.rb", "test/test_helper.rb"]
  s.homepage = "http://eaal.rubyforge.org"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "eaal"
  s.rubygems_version = "1.8.23"
  s.summary = "EAAL (Eve API Access Layer) is a ruby library for accessing data of the API of the game Eve Online"
  s.test_files = ["test/test_eaal.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 1.7.1"])
      s.add_runtime_dependency(%q<faraday>, [">= 0.8.4"])
      s.add_development_dependency(%q<hoe>, [">= 0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
      s.add_dependency(%q<memcache-client>, [">= 1.7.1"])
      s.add_dependency(%q<faraday>, [">= 0.8.4"])
      s.add_dependency(%q<hoe>, [">= 0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
    s.add_dependency(%q<memcache-client>, [">= 1.7.1"])
    s.add_dependency(%q<faraday>, [">= 0.8.4"])
    s.add_dependency(%q<hoe>, [">= 0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 0"])
  end
end
