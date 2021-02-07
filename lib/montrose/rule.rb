# frozen_string_literal: true

module Montrose
  # Defines the Rule duck type for recurrence rules
  module Rule
    def self.included(base)
      base.extend ClassMethods
    end

    def include?(_time)
      fail "Class must implement #{__method__}"
    end

    def advance!(_time)
      true
    end

    def continue?(_time = nil)
      true
    end

    module ClassMethods
      def apply_option(_opts)
        nil
      end

      def apply_options?(opts)
        apply_options(opts)
      end

      def from_options(opts)
        new(apply_options(opts)) if apply_options?(opts)
      end
    end
  end
end

require "montrose/rule/after"
require "montrose/rule/covering"
require "montrose/rule/day_of_month"
require "montrose/rule/day_of_week"
require "montrose/rule/day_of_year"
require "montrose/rule/during"
require "montrose/rule/except"
require "montrose/rule/minute_of_hour"
require "montrose/rule/hour_of_day"
require "montrose/rule/month_of_year"
require "montrose/rule/nth_day_of_month"
require "montrose/rule/nth_day_of_year"
require "montrose/rule/time_of_day"
require "montrose/rule/total"
require "montrose/rule/until"
require "montrose/rule/week_of_year"
