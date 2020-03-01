# -*- mode: enh-ruby -*-
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphviz/vocab/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphviz-vocab'
  spec.version       = ::GraphViz::Vocab::VERSION
  spec.authors       = ['Dorian Taylor']
  spec.email         = ['code@doriantaylor.com']
  spec.license       = 'Apache-2.0'
  spec.homepage      = 'https://github.com/doriantaylor/rb-graphviz-vocab'
  spec.summary       = 'Single-purpose tool to convert GraphViz spec to OWL'
  spec.description   = <<-DESC

  DESC

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is
  # released.  The `git ls-files -z` loads the files in the RubyGem
  # that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # ruby
  spec.required_ruby_version = '~> 2.5'

  # dev/test dependencies
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake',    '~> 13.0'
  spec.add_development_dependency 'rspec',   '~> 3.9'

  # stuff we use
  spec.add_runtime_dependency 'rdf',         '~> 3.1.1'
  spec.add_runtime_dependency 'rest-client', '~> 2.1.0'
  spec.add_runtime_dependency 'commander',   '~> 4.4.7'
  spec.add_runtime_dependency 'tidy_ffi',    '~> 1.0.0'
  spec.add_runtime_dependency 'nokogiri',    '~> 1.10.4'

  # stuff i wrote
  spec.add_runtime_dependency 'xml-mixup',   '~> 0.1.10'
end
