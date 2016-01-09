module Montrose
  module Rule
    class DayOfYear
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:yday]
      end

      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.include?(time.yday)
      end
    end
  end
end
