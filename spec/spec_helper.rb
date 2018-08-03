# frozen_string_literal: true

require "bundler/setup"
require "pagopa_soap"
require "pry"

support_files = File.expand_path("spec/support/**/*.rb")
Dir[support_files].each { |file| require file }

require "webmock/rspec"
WebMock.disable_net_connect!

RSpec.configure do |config|
 #  config.include Savon::SpecHelper
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SpecSupport
end
