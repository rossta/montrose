module Montrose
  module Rule
    class Before
      include Montrose::Rule

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
