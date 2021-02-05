# frozen_string_literal: true

require "montrose/time_of_day"

module Montrose
  module Rule
    class During
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:during]
      end

      # Initializes rule
      #
      # @param during [Array<Array<Fixnum>>] array of time parts arrays, e.g. [[9, 0, 0], [17, 0, 0]], i.e., "9 to 5"
      #
      def initialize(during)
        @during = during.map { |first, last| TimeOfDayRange.new(first, last) }
      end

      def include?(time)
        @during.any? { |range| range.include?(time) }
      end

      class TimeOfDayRange
        def initialize(first, last, exclude_end: false)
          @first = ::Montrose::TimeOfDay.new(first)
          @last = ::Montrose::TimeOfDay.new(last)
          @exclude_end = exclude_end
        end

        def include?(time)
          range.include?(time.seconds_since_midnight.to_i)
        end

        private

        def range
          @range ||= Range.new(
            @first.seconds_since_midnight,
            @last.seconds_since_midnight,
            @exclude_end
          )
        end
      end
    end
  end
end
