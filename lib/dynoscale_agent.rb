# frozen_string_literal: true

require 'dynoscale_agent/version'
require 'dynoscale_agent/railtie' if defined?(Rails::Railtie) && Rails::Railtie.respond_to?(:initializer)

module DynoscaleAgent
  class Error < StandardError; end
end
