module Montrose
  module Rule
    class WeekOfYear
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:week]
      end

      # Initializes rule
      #
      # @param [Array[Fixnum]] weeks - valid weeks of year
      #
      def initialize(weeks)
        @weeks = weeks
      end

      def include?(time)
        @weeks.include?(time.to_date.cweek)
      end
    end
  end
end
