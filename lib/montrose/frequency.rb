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

    def self.assert(frequency)
      FREQUENCY_TERMS.key?(frequency.to_s) or
        raise "Don't know how to enumerate every: #{frequency}"

      frequency
    end

    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @starts = opts[:starts]
      @interval = opts.fetch(:interval, 1)
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
