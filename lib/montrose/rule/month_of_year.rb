# frozen_string_literal: true
module Montrose
  module Rule
    class MonthOfYear
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:month]
      end

      # Initializes rule
      #
      # @param [Array] months - valid month numbers
      #
      def initialize(months)
        @months = months
      end

      def include?(time)
        @months.include?(time.month)
      end
    end
  end
end
