module Montrose
  class Clock
    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
    end

    def tick
      @time = peek
    end

    def peek
      return @starts if @time.nil?

      @time.advance(step)
    end

    def step
      @step ||= smallest_step or raise "No step for #{@options.inspect}"
    end

    def smallest_step
      minute_step || hour_step || day_step || week_step || month_step || year_step
    end

    def minute_step
      if @options.key?(:minute)
        { minutes: 1 }
      elsif @options[:every] == :minute
        { minutes: @interval }
      end
    end

    def hour_step
      if @options.key?(:hour)
        { hours: 1 }
      elsif @options[:every] == :hour
        { hours: @interval }
      end
    end

    def day_step
      if @options.key?(:day) || @options.key?(:mday) || @options.key?(:yday)
        { days: 1 }
      elsif @options[:every] == :day
        { days: @interval }
      end
    end

    def week_step
      if @options.key?(:week)
        { weeks: 1 }
      elsif @options[:every] == :week
        { weeks: @interval }
      end
    end

    def month_step
      if @options.key?(:month)
        { months: 1 }
      elsif @options[:every] == :month
        { months: @interval }
      end
    end

    def year_step
      if @options.key?(:year)
        { years: 1 }
      elsif @options[:every] == :year
        { years: @interval }
      end
    end
  end
end
