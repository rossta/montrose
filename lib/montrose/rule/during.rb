# frozen_string_literal: true

module Montrose
  module Rule
    class During
      include Montrose::Rule

      def self.apply_options(opts)
        return false unless opts[:during]

        {during: opts[:during], exclude_end: opts.fetch(:exclude_end, false)}
      end

      def initialize(opts)
        case opts
        when Hash
          during = opts.fetch(:during)
          @exclude_end = opts.fetch(:exclude_end, false)
        else
          during = opts
          @exclude_end = false
        end

        @during = during.map { |first, last| TimeOfDayRange.new(first, last, exclude_end: @exclude_end) }
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
