module Montrose
  module Rule
    class Before
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:until]
      end

      def initialize(end_time)
        @end_time = end_time
      end

      def include?(time)
        time < @end_time
      end

      def break?
        raise StopIteration
      end
    end
  end
end
