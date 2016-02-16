module Montrose
  module Rule
    class Except
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:except]
      end

      # Initializes rule
      #
      # @param [Date] dates - array of date objects
      #
      def initialize(dates)
        @dates = dates
      end

      def include?(time)
        !@dates.include?(time.to_date)
      end

      def continue?
        true
      end
    end
  end
end
