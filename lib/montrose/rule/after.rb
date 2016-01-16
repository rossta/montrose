module Montrose
  module Rule
    class After
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:starts]
      end

      # Initializes rule
      #
      # @param [Time] start_time - lower bound timestamp
      #
      def initialize(start_time)
        @start_time = start_time
      end

      def include?(time)
        time >= @start_time
      end

      def continue?
        false
      end
    end
  end
end
