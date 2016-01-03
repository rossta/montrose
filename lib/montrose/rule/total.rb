module Montrose
  module Rule
    class Total
      include Montrose::Rule

      def initialize(max)
        @max = max
        @count = 0
      end

      def include?(_time)
        @count <= @max
      end

      def advance!(_time)
        @count += 1
        break?
      end

      def continue?
        @count <= @max
      end

      def break?
        continue? or raise StopIteration
      end
    end
  end
end
