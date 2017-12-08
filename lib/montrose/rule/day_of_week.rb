# frozen_string_literal: true

module Montrose
  module Rule
    class DayOfWeek
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:day]
      end

      # Initializes rule
      #
      # @param [Array<Fixnum>] days - valid days of week, e.g. [1, 2, 7]
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.include?(time.wday)
      end
    end
  end
end
