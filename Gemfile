# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rspec'
gem 'rubocop'
gem 'rubocop-extension-generator'
gem 'debug'

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
