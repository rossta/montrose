module Montrose
  class TimeOfDay
    include Comparable

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

    def <=>(other)
      to_a <=> other.to_a
    end
  end
end
