# frozen_string_literal: true

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

      def include?(time)
        continue?(time)
      end

      def advance!(time)
        @count += 1
        continue?(time)
      end

      def continue?(_time)
        @count <= @max
      end
    end
  end
end
