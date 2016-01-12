module Montrose
  module Rule
    class After
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:starts]
      end

      # Initializes rule
      #
      # @param [Array<Fixnum>] days - valid days of month, i.e. [1, 2, -1]
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
