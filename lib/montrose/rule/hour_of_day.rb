module Montrose
  module Rule
    class HourOfDay
      include Montrose::Rule

      def initialize(hours)
        @hours = hours.to_a.compact
      end

      def include?(time)
        @hours.include?(time.hour)
      end
    end
  end
end
