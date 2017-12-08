# frozen_string_literal: true

module Montrose
  module Rule
    class HourOfDay
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:hour]
      end

      # Initializes rule
      #
      # @param hours [Array<Fixnum>] valid hours of days, e.g. [1, 2, 24]
      #
      def initialize(hours)
        @hours = hours
      end

      def include?(time)
        @hours.include?(time.hour)
      end
    end
  end
end
