module Montrose
  module Rule
    class TimeOfDay
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Array<Time>] times - valid hours of days
      #
      def initialize(times)
        @times = times
      end

      def include?(time)
        times_of_day.include?(parts(time))
      end

      private

      def parts(time)
        [time.hour, time.min]
      end

      def times_of_day
        @times_of_day ||= @times.map { |t| parts(t) }
      end
    end
  end
end
