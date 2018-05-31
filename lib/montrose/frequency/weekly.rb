# frozen_string_literal: true

module Montrose
  class Frequency
    class Weekly < Frequency
      def include?(time)
        (weeks_since_start(time) % @interval).zero?
      end

      def to_cron
        raise "Intervals unsupported" unless @interval == 1
        "#{@starts.min} #{@starts.hour} * * #{@starts.wday}"
      end

      private

      def weeks_since_start(time)
        ((time.beginning_of_week - base_date) / 1.week).round
      end

      def base_date
        @starts.beginning_of_week
      end
    end
  end
end
