require "montrose/errors"
require "montrose/options"

module Montrose
  # Abstract class for special recurrence rule required
  # in all instances of Recurrence. Frequency describes
  # the base recurrence interval.
  #
  class Frequency
    include Montrose::Rule

    FREQUENCY_TERMS = {
      "minute" => "Minutely",
      "hour" => "Hourly",
      "day" => "Daily",
      "week" => "Weekly",
      "month" => "Monthly",
      "year" => "Yearly"
    }.freeze

    FREQUENCY_KEYS = FREQUENCY_TERMS.keys.freeze

    attr_reader :time, :starts

    # Factory method for instantiating the appropriate Frequency
    # subclass.
    #
    def self.from_options(opts)
      frequency = opts.fetch(:every) { fail ConfigurationError, "Please specify the :every option" }
      class_name = FREQUENCY_TERMS.fetch(frequency.to_s) do
        fail "Don't know how to enumerate every: #{frequency}"
      end

      Montrose::Frequency.const_get(class_name).new(opts)
    end

    # @private
    def self.assert(frequency)
      FREQUENCY_TERMS.key?(frequency.to_s) or fail ConfigurationError,
        "Don't know how to enumerate every: #{frequency}"

      frequency.to_sym
    end

    def initialize(opts = {})
      opts = Montrose::Options.merge(opts)
      @time = nil
      @starts = opts.fetch(:starts)
      @interval = opts.fetch(:interval)
    end

    def matches_interval?(time_diff)
      (time_diff % @interval).zero?
    end
  end
end

require "montrose/frequency/daily"
require "montrose/frequency/hourly"
require "montrose/frequency/minutely"
require "montrose/frequency/monthly"
require "montrose/frequency/weekly"
require "montrose/frequency/yearly"
