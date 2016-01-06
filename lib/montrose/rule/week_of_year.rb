module Montrose
  module Rule
    class WeekOfYear
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Array[Fixnum]] weeks - valid weeks of year
      #
      def initialize(weeks)
        @weeks = [*weeks].compact
      end

      def include?(time)
        @weeks.include?(time.to_date.cweek)
      end
    end
  end
end
