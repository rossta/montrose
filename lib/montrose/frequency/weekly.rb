module Montrose
  class Frequency
    class Weekly < Frequency
      def include?(time)
        (weeks_since_start(time) % @interval).zero?
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
