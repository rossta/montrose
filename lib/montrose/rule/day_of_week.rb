module Montrose
  module Rule
    class DayOfWeek
      include Montrose::Rule

      def initialize(days)
        @days = [*days].compact.map { |d| Montrose::Utils.day_number(d) }
      end

      def include?(time)
        @days.include?(time.wday)
      end
    end
  end
end
