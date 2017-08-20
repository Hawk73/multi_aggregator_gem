# frozen_string_literal: true

require 'bundler/setup'
require 'multi_aggregator'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include AdapterHelper
  config.include PgHelper
  config.include QueryHelper

  # config.use_transactional_fixtures = false
  # def without_transactional_fixtures(&block)
  #
  #   before(:all) do
  #     DatabaseCleaner.strategy = :truncation
  #   end
  #
  #   yield
  #
  #   after(:all) do
  #     DatabaseCleaner.strategy = :transaction
  #   end
  # end
end
