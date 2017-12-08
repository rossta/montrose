# frozen_string_literal: true

require "forwardable"

module Montrose
  module Rule
    class NthDayMatcher
      extend Forwardable

      def_delegators :@period_day, :nth_day, :first_wday, :total_days

      def initialize(wday, period_day)
        @wday = wday
        @period_day = period_day
      end

      def matches?(nth_occ)
        nth_occ == current_occ || (nth_occ < 0 && (total_occ + nth_occ + 1) == current_occ)
      end

      private

      def current_occ
        @current_occ ||= (nth_day - first_occ) / 7 + 1
      end

      def total_occ
        @total_occ ||= ((total_days - first_occ + 1) / 7.0).ceil
      end

      def first_occ
        @first_occ ||= ((7 - first_wday) + @wday) % 7 + 1
      end
    end
  end
end
