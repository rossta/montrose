module Montrose
  module Rule
    class DayOfMonth
      include Montrose::Rule

      def initialize(days)
        @days = [*days].compact
      end

      def include?(time)
        @days.include?(time.mday) || included_from_end_of_month?(time)
      end

      private

      # matches days specified at negative numbers
      def included_from_end_of_month?(time)
        month_days = Time.days_in_month(time.month, time.year) # given by activesupport
        @days.any? { |d| month_days + d + 1 == time.mday }
      end
    end
  end
end
