module Montrose
  class TimeOfDay
    include Comparable

    attr_reader :parts, :hour, :min, :sec

    def self.parse(arg)
      return new(arg) if arg.is_a?(Array)

      from_time(::Montrose::Utils.as_time(arg))
    end

    def self.from_time(time)
      new([time.hour, time.min, time.sec])
    end

    def initialize(parts)
      @parts = parts
      @hour, @min, @sec = *parts
    end

    def seconds_since_midnight
      @seconds_since_midnight ||= (@hour * 60 * 60) + (@min * 60) + @sec
    end

    def to_a
      @parts
    end

    # def inspect
    #   "#<Montrose::TimeOfDay #{format_time(@hour)}:#{format_time(@min)}:#{format_time(@sec)}"
    # end

    def <=>(other)
      to_a <=> other.to_a
    end

    private

    def format_time(part)
      format("%02d", part)
    end
  end
end
