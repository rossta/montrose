# frozen_string_literal: true

module Montrose
  module Rule
    class DayOfMonth
      include Montrose::Rule

      def self.apply_options(opts)
        opts[:mday]
      end

      # Initializes rule
      #
      # @param [Hash] opts `mday` valid days of month, and `skip_months` options
      #
      def initialize(opts)
        @days = opts.fetch(:default)
        @overrides = opts.fetch(:overrides, {})
        @fallback = opts.fetch(:fallback, nil)
      end

      def include?(time)
        return override?(time) if has_override?(month_name(time))

        @days.include?(time.mday) || included_from_end_of_month?(time) || fallback?(time)
      end

      private

      # matches days specified at negative numbers
      def included_from_end_of_month?(time, days = @days)
        days_in_month = month_days(time)
        days.any? { |d| days_in_month + d + 1 == time.mday }
      end

      def has_override?(month)
        @overrides.key?(month)
      end

      def override?(time)
        return false if @overrides.blank?

        time.day == @overrides[month_name(time)]
      end

      def month_name(time)
        time.strftime("%B").downcase.to_sym
      end

      def fallback?(time)
        days_in_month = month_days(time)

        return false if @fallback.blank?
        # If any negative days, we will always have a match
        return false if @days.any?(&:negative?)
        # If all days are < number of days in this month, we'll always have a match
        return false if @days.all? { |d| d <= days_in_month }

        time.day == @fallback || included_from_end_of_month?(time, [@fallback])
      end

      def month_days(time)
        ::Montrose::Utils.days_in_month(time.month, time.year) # given by activesupport
      end
    end
  end
end
