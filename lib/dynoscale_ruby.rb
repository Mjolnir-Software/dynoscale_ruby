# frozen_string_literal: true

require 'dynoscale_ruby/version'
require 'dynoscale_ruby/railtie' if defined?(Rails::Railtie) && Rails::Railtie.respond_to?(:initializer)

module DynoscaleRuby
  class Error < StandardError; end
end
