module Montrose
  module Rule
    class TimeOfDay
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:at]
      end

      # Initializes rule
      #
      # @param [Array<Time>] times - valid hours of days
      #
      def initialize(times)
        @times = times
      end

      def include?(time)
        @times.include?(parts(time))
      end

      private

      def parts(time)
        [time.hour, time.min]
      end
    end
  end
end
