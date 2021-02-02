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
        @covering = case covering.first
        when Date
          DateRange.new(covering)
        else
          covering
        end
      end

      def include?(time)
        @covering.include?(time)
      end

      def continue?(time)
        time < @covering.last
      end

      class DateRange < SimpleDelegator
        def include?(time)
          __getobj__.include?(time.to_date)
        end
      end
    end
  end
end
