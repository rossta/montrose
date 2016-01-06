module Montrose
  module Rule
    class MonthOfYear
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Array] months - valid month numbers
      #
      def initialize(months)
        @months = months
      end

      def include?(time)
        @months.include?(time.month)
      end
    end
  end
end
