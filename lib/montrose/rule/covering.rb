# frozen_string_literal: true

module Montrose
  module Rule
    class Covering
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:covering].is_a?(Range) && opts[:covering]
      end

      # Initializes rule
      #
      # @param [Range] covering - timestamp range
      #
      def initialize(covering)
        @covering = covering
      end

      def include?(time)
        @covering.cover?(time)
      end

      def continue?(time)
        time < @covering.max
      end
    end
  end
end
