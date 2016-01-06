module Montrose
  module Rule
    class HourOfDay
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Array<Fixnum>] hour - valid hours of days
      #
      def initialize(hours)
        @hours = hours
      end

      def include?(time)
        @hours.include?(time.hour)
      end
    end
  end
end
