# frozen_string_literal: true

module Montrose
  class Frequency
    class Hourly < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.hour)
      end

      def to_cron
        "#{@starts.min} #{interval_str} * * *"
      end
    end
  end
end
