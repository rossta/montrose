# frozen_string_literal: true

module Montrose
  Error = Class.new(StandardError)
  ConfigurationError = Class.new(Error)
  SerializationError = Class.new(Error)
end
