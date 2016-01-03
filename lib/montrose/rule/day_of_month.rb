module Montrose
  module Rule
    class DayOfMonth
      include Montrose::Rule

      def initialize(days)
        @days = [*days].compact
      end

      def include?(time)
        @days.include?(time.mday) || begin
        month_days = days_in_month(time)
        @days.any? { |d| month_days + d + 1 == time.mday }
        end
      end

      # Get the days in the month for +time
      def days_in_month(time)
        date = Date.new(time.year, time.month, 1)
        ((date >> 1) - date).to_i
      end
    end
  end
end
