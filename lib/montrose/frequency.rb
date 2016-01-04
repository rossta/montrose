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
      term = FREQUENCY_TERMS.fetch(frequency.to_s) do
        raise "Don't know how to enumerate every: #{opts[:every]}"
      end

      Montrose::Frequency.const_get(term).new(opts)
    end

    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @count = 0
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
      @repeat = opts.fetch(:repeat, nil)
    end

    def advance!(time)
      increment!(time)
      self.break?
    end

    def break?
      continue?(time) or raise StopIteration
    end

    def continue?(_time)
      return true unless @repeat
      @count <= @repeat
    end

    def increment!(_time)
      @count += 1
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

      def increment!(time)
        @weeks ||= Set.new
        @weeks << weeks_since_start(time)
        @count = @weeks.count
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
