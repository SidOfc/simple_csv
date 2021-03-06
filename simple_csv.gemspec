# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_csv/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_csv'
  spec.version       = SimpleCsv::VERSION
  spec.authors       = ['Sidney Liebrand']
  spec.email         = ['sidneyliebrand@gmail.com']

  spec.summary       = 'CSV DSL'
  spec.description   = 'A simple DSL for reading and generating CSV files'
  spec.homepage      = 'https://github.com/SidOfc/simple_csv'
  spec.license       = 'MIT'

  spec.metadata = {
    'documentation_uri' => 'https://github.com/SidOfc/simple_csv'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'coveralls'
end
