# frozen_string_literal: true

require_relative 'lib/legion/extensions/attention_spotlight/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-attention-spotlight'
  spec.version       = Legion::Extensions::AttentionSpotlight::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Attention Spotlight'
  spec.description   = 'Spotlight model of attention (Posner + Eriksen zoom lens) for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-attention-spotlight'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-attention-spotlight'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-attention-spotlight'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-attention-spotlight'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-attention-spotlight/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-attention-spotlight.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
