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

    def self.from_options(opts)
      frequency = opts.fetch(:every) { raise "Please specify the :every option" }

      Montrose::Frequency.const_get(fetch(frequency)).new(opts)
    end

    def self.fetch(frequency)
      FREQUENCY_TERMS.fetch(frequency.to_s) do
        raise "Don't know how to enumerate every: #{frequency}"
      end
    end

    # Convert input to frequency hash
    def self.parse(input)
      if input.is_a?(Numeric)
        frequency, interval = duration_to_frequency_parts(input)
        { every: frequency, interval: interval }
      else
        { every: Frequency.assert(input) }
      end
    end

    # @private
    def self.assert(frequency)
      FREQUENCY_TERMS.key?(frequency.to_s) or
        raise "Don't know how to enumerate every: #{frequency}"

      frequency.to_sym
    end

    # @private
    def self.duration_to_frequency_parts(duration)
      parts = nil
      [:year, :month, :week, :day, :hour, :minute].each do |freq|
        div, mod = duration.divmod(1.send(freq))
        parts = [freq, div]
        return parts if mod.zero?
      end
      parts
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

    class Minutely < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.minute)
      end
    end

    class Hourly < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.hour)
      end
    end

    class Daily < Frequency
      def include?(time)
        matches_interval? time.to_date - @starts.to_date
      end
    end

    class Weekly < Frequency
      def include?(time)
        weeks_since_start(time) % @interval == 0
      end

      private

      def weeks_since_start(time)
        ((time.beginning_of_week - base_date) / 1.week).round
      end

      def base_date
        @starts.beginning_of_week
      end
    end

    class Monthly < Frequency
      def include?(time)
        matches_interval?((time.month - @starts.month) + (time.year - @starts.year) * 12)
      end
    end

    class Yearly < Frequency
      def include?(time)
        matches_interval? time.year - @starts.year
      end
    end
  end
end