# frozen_string_literal: true

module Montrose
  class Frequency
    class Yearly < Frequency
      def include?(time)
        matches_interval? time.year - @starts.year
      end

      def to_cron
        raise "Intervals unsupported" unless @interval == 1
        "#{@starts.min} #{@starts.hour} #{@starts.day} #{@starts.month} *"
      end
    end
  end
end
