module Montrose
  module Rule
    class DayOfWeek
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Array<Fixnum>] days - valid days of week
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.include?(time.wday)
      end
    end
  end
end
