# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/object"

require "active_support/core_ext/date"
require "active_support/core_ext/date_time"
require "active_support/core_ext/integer"
require "active_support/core_ext/numeric"
require "active_support/core_ext/string"
require "active_support/core_ext/time"

require "montrose/version"
require "montrose/errors"

module Montrose
  autoload :Chainable, "montrose/chainable"
  autoload :Clock, "montrose/clock"
  autoload :Day, "montrose/day"
  autoload :Frequency, "montrose/frequency"
  autoload :Hour, "montrose/hour"
  autoload :ICal, "montrose/ical"
  autoload :Minute, "montrose/minute"
  autoload :Month, "montrose/month"
  autoload :MonthDay, "montrose/month_day"
  autoload :Options, "montrose/options"
  autoload :Recurrence, "montrose/recurrence"
  autoload :Rule, "montrose/rule"
  autoload :TimeOfDay, "montrose/time_of_day"
  autoload :Schedule, "montrose/schedule"
  autoload :Stack, "montrose/stack"
  autoload :Utils, "montrose/utils"
  autoload :Week, "montrose/week"
  autoload :YearDay, "montrose/year_day"

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

    # Create a new recurrence from given options
    # An alias to {Montrose::Recurrence.new}
    attr_reader :enable_deprecated_between_masking

    def enable_deprecated_between_masking=(value)
      warn "[DEPRECATION] Montrose.enable_deprecated_between_masking is deprecated and will be removed in a future version."
      @enable_deprecated_between_masking = value
    end

    def enable_deprecated_between_masking?
      result = !!enable_deprecated_between_masking
      if result
        warn "[DEPRECATION] Legacy Montrose.between masking behavior is deprecated. Please use Montrose.covering instead to retain this behavior."
      end
      result
    end
  end
end
