# frozen_string_literal: true

module Montrose
  # Abstract class for special recurrence rule required
  # in all instances of Recurrence. Frequency describes
  # the base recurrence interval.
  #
  class Frequency
    autoload :Daily, "montrose/frequency/daily"
    autoload :Hourly, "montrose/frequency/hourly"
    autoload :Minutely, "montrose/frequency/minutely"
    autoload :Monthly, "montrose/frequency/monthly"
    autoload :Secondly, "montrose/frequency/secondly"
    autoload :Weekly, "montrose/frequency/weekly"
    autoload :Yearly, "montrose/frequency/yearly"

    include Montrose::Rule

    FREQUENCY_TERMS = {
      "second" => "Secondly",
      "minute" => "Minutely",
      "hour" => "Hourly",
      "day" => "Daily",
      "week" => "Weekly",
      "month" => "Monthly",
      "year" => "Yearly"
    }.freeze

    FREQUENCY_KEYS = FREQUENCY_TERMS.keys.freeze

    attr_reader :time, :starts

    class << self
      def parse(input)
        if input.respond_to?(:parts)
          frequency, interval = duration_to_frequency_parts(input)
          {every: frequency.to_s.singularize.to_sym, interval: interval}
        elsif input.is_a?(Numeric)
          frequency, interval = numeric_to_frequency_parts(input)
          {every: frequency, interval: interval}
        else
          {every: Frequency.assert(input)}
        end
      end

      # Factory method for instantiating the appropriate Frequency
      # subclass.
      #
      def from_options(opts)
        frequency = opts.fetch(:every) { fail ConfigurationError, "Please specify the :every option" }
        class_name = FREQUENCY_TERMS.fetch(frequency.to_s) {
          fail "Don't know how to enumerate every: #{frequency}"
        }

        Montrose::Frequency.const_get(class_name).new(opts)
      end

      def from_term(term)
        FREQUENCY_TERMS.invert.map { |k, v| [k.downcase, v] }.to_h.fetch(term.downcase) do
          fail "Don't know how to convert #{term} to a Montrose frequency"
        end
      end

      # @private
      def assert(frequency)
        FREQUENCY_TERMS.key?(frequency.to_s) || fail(ConfigurationError,
          "Don't know how to enumerate every: #{frequency}")

        frequency.to_sym
      end

      # @private
      def numeric_to_frequency_parts(number)
        parts = nil
        %i[year month week day hour minute].each do |freq|
          div, mod = number.divmod(1.send(freq))
          parts = [freq, div]
          return parts if mod.zero?
        end
        parts
      end

      # @private
      def duration_to_frequency_parts(duration)
        duration.parts.first
      end
    end

    def initialize(opts = {})
      opts = Montrose::Options.merge(opts)
      @time = nil
      @starts = opts.fetch(:start_time)
      @interval = opts.fetch(:interval)
    end

    def matches_interval?(time_diff)
      (time_diff % @interval).zero?
    end

    def to_cron
      raise "abstract"
    end

    protected

    def interval_str
      @interval != 1 ? "*/#{@interval}" : "*"
    end
  end
end
