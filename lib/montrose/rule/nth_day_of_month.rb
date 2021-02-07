# frozen_string_literal: true

module Montrose
  module Rule
    class NthDayOfMonth
      include Montrose::Rule

      def self.apply_options?(opts)
        (opts[:every] == :month || opts[:month]) && opts[:day].is_a?(Hash)
      end

      def self.apply_options(opts)
        opts[:day]
      end

      # Initializes rule
      #
      # @param [Hash] days - valid days of week to month occurrence pairs
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.key?(time.wday) && nth_day?(time)
      end

      private

      def nth_day?(time)
        expected_occurrences = @days[time.wday]
        nth_day = NthDayMatcher.new(time.wday, MonthDay.new(time))
        expected_occurrences.any? { |n| nth_day.matches?(n) }
      end

      class MonthDay
        def initialize(time)
          @time = time
        end

        def nth_day
          @time.mday
        end

        def first_wday
          @time.beginning_of_month.wday
        end

        def total_days
          ::Montrose::Utils.days_in_month(@time.month, @time.year)
        end
      end
    end
  end
end
