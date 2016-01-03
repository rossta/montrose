module Montrose
  class Frequency
    include Montrose::Rule

    attr_reader :time, :starts

    def self.from_options(opts)
      case opts[:every]
      when :year
        Yearly.new(opts)
      when :week
        Weekly.new(opts)
      when :month
        Monthly.new(opts)
      when :day
        Daily.new(opts)
      when :hour
        Hourly.new(opts)
      when :minute
        Minutely.new(opts)
      else
        raise "Don't know how to enumerate every: #{opts[:every]}"
      end
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
      (time_diff.to_i % @interval).zero?
    end
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
