# -*- encoding: utf-8 -*-
# stub: ood_support 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "ood_support".freeze
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jeremy Nicklas".freeze]
  s.date = "2017-11-17"
  s.description = "Provides an interface to working with the local OS installed on the HPC Center's web node.".freeze
  s.email = ["jnicklas@osc.edu".freeze]
  s.homepage = "https://github.com/OSC/ood_support".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Open OnDemand gem that adds useful support methods for an HPC Center.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
