# frozen_string_literal: true

module Montrose
  module Rule
    class TimeOfDay
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:at]
      end

      # Initializes rule
      #
      # @param [Array<Time>] times - valid times
      #
      def initialize(times)
        @times = times
      end

      def include?(time)
        @times.include?(parts(time))
      end

      private

      def parts(time)
        ::Montrose::TimeOfDay.to_parts(time)
      end
    end
  end
end
