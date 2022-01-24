# -*- encoding: utf-8 -*-
# stub: ood_core 0.17.6 ruby lib

Gem::Specification.new do |s|
  s.name = "ood_core".freeze
  s.version = "0.17.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Franz".freeze, "Morgan Rodgers".freeze, "Jeremy Nicklas".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-08-24"
  s.description = "Open OnDemand core library that provides support for an HPC Center to globally define HPC services that web applications can then take advantage of.".freeze
  s.email = ["efranz@osc.edu".freeze, "mrodgers@osc.edu".freeze, "jnicklas@osc.edu".freeze]
  s.homepage = "https://github.com/OSC/ood_core".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Open OnDemand core library".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<ood_support>.freeze, ["~> 0.0.2"])
    s.add_runtime_dependency(%q<ffi>.freeze, ["~> 1.9", ">= 1.9.6"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.2", "< 6.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.10"])
    s.add_development_dependency(%q<timecop>.freeze, ["~> 0.8"])
    s.add_development_dependency(%q<climate_control>.freeze, ["~> 0.2.0"])
  else
    s.add_dependency(%q<ood_support>.freeze, ["~> 0.0.2"])
    s.add_dependency(%q<ffi>.freeze, ["~> 1.9", ">= 1.9.6"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.1"])
    s.add_dependency(%q<activesupport>.freeze, [">= 5.2", "< 6.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.10"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
    s.add_dependency(%q<climate_control>.freeze, ["~> 0.2.0"])
  end
end
