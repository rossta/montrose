module Montrose
  module Rule
    class After
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:starts]
      end

      def initialize(start_time)
        @start_time = start_time
      end

      def include?(time)
        time >= @start_time
      end

      def break?
        raise StopIteration
      end
    end
  end
end
