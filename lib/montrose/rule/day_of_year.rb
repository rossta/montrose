module Montrose
  module Rule
    class DayOfYear
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:yday]
      end

      # Initializes rule
      #
      # @param [Array<Fixnum>] days - valid days of year, e.g. [1, 2, 366]
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.include?(time.yday)
      end
    end
  end
end
