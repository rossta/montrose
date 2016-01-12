module Montrose
  module Rule
    class Total
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:total]
      end

      def initialize(max)
        @max = max
        @count = 0
      end

      def include?(_time)
        continue?
      end

      def advance!(_time)
        @count += 1
        continue?
      end

      def continue?
        @count <= @max
      end
    end
  end
end
