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
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'

  # stuff we use
  spec.add_runtime_dependency 'rdf', '~> 3.0.2'
  
end
