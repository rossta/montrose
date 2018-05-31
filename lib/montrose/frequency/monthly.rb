# frozen_string_literal: true

module Montrose
  class Frequency
    class Monthly < Frequency
      def include?(time)
        matches_interval?((time.month - @starts.month) + (time.year - @starts.year) * 12)
      end

      def to_cron
        "#{@starts.min} #{@starts.hour} #{@starts.day} #{interval_str} *"
      end
    end
  end
end
