# frozen_string_literal: true

module Montrose
  module Rule
    class DayOfYear
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:yday]
      end

      # Initializes rule
      #
      # @param [Array<Fixnum>] days - valid days of year, e.g. [1, 2, -1]
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.include?(time.yday) || included_from_end_of_month?(time)
      end

      private

      def included_from_end_of_month?(time)
        year_days = ::Montrose::Utils.days_in_year(time.year) # given by activesupport
        @days.any? { |d| year_days + d + 1 == time.yday }
      end
    end
  end
end
