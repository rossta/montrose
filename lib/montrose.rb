# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/object"
require "active_support/core_ext/numeric"
require "active_support/core_ext/date"
require "active_support/core_ext/time"
require "active_support/core_ext/date_time"

require "montrose/utils"
require "montrose/rule"
require "montrose/clock"
require "montrose/chainable"
require "montrose/recurrence"
require "montrose/frequency"
require "montrose/schedule"
require "montrose/stack"
require "montrose/version"

module Montrose
  extend Chainable

  class << self
    # Create a new recurrence from given options
    # An alias to {Montrose::Recurrence.new}
    #
    # @param options [Hash] recurrence options
    #
    # @example
    #   Montrose.recurrence(every: :day)
    #   Montrose.r(every: :day)
    #
    # @return [Montrose::Recurrence]
    #
    def recurrence(options = {})
      branch(options)
    end
    alias_method :r, :recurrence
  end
end
