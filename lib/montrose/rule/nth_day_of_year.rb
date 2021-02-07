# frozen_string_literal: true

module Montrose
  module Rule
    class NthDayOfYear
      include Montrose::Rule

      def self.apply_options?(opts)
        opts[:every] == :year && !opts[:month] && opts[:day].is_a?(Hash)
      end

      def self.apply_options(opts)
        opts[:day]
      end

      # Initializes rule
      #
      # @param [Hash] days - valid days of week to year occurrence pairs
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
        nth_day = NthDayMatcher.new(time.wday, YearDay.new(time))
        expected_occurrences.any? { |n| nth_day.matches?(n) }
      end

      class YearDay
        def initialize(time)
          @time = time
        end

        def nth_day
          @time.yday
        end

        def first_wday
          @time.beginning_of_year.wday
        end

        def total_days
          days_in_year(@time)
        end

        private

        # Get the days in the month for +time
        def days_in_year(time)
          date = time.to_date
          ((date + 1.year) - date).to_i
        end
      end
    end
  end
end
