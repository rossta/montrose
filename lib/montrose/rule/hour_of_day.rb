module Montrose
  module Rule
    class HourOfDay
      def initialize(hours)
        @hours = [*hours].compact
      end

      def include?(time)
        @hours.include?(time.hour)
      end

      def advance!(time)
      end

      def break?
      end
    end
  end
end
