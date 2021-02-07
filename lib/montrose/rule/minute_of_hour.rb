# frozen_string_literal: true

module Montrose
  module Rule
    class MinuteOfHour
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:minute]
      end

      # Initializes rule
      #
      # @param minutes [Array<Fixnum>] valid minutes of hour, e.g. [0, 20, 59]
      #
      def initialize(minutes)
        @minutes = minutes
      end

      def include?(time)
        @minutes.include?(time.min)
      end
    end
  end
end
