# frozen_string_literal: true

module Montrose
  module Rule
    class Between
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:between].is_a?(Range) && opts[:between]
      end

      # Initializes rule
      #
      # @param [Range] between - timestamp range
      #
      def initialize(between)
        @between = between
      end

      def include?(time)
        @between.cover?(time)
      end

      def continue?(time)
        time < @between.max
      end
    end
  end
end
