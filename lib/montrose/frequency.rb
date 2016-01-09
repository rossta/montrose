module Montrose
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

    def self.apply?(*)
      true
    end

    def self.from_options(opts)
      frequency = opts.fetch(:every) { raise "Please specify the :every option" }

      Montrose::Frequency.const_get(fetch(frequency)).new(opts)
    end

    def self.fetch(frequency)
      FREQUENCY_TERMS.fetch(frequency.to_s) do
        raise "Don't know how to enumerate every: #{frequency}"
      end
    end

    # @private
    def self.assert(frequency)
      FREQUENCY_TERMS.key?(frequency.to_s) or
        raise "Don't know how to enumerate every: #{frequency}"

      frequency.to_sym
    end

    def initialize(opts = {})
      opts = Montrose::Options.new(opts)
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
