# frozen_string_literal: true

module Montrose
  # Defines the Rule duck type for recurrence rules
  module Rule
    autoload :After, "montrose/rule/after"
    autoload :Covering, "montrose/rule/covering"
    autoload :DayOfMonth, "montrose/rule/day_of_month"
    autoload :DayOfWeek, "montrose/rule/day_of_week"
    autoload :DayOfYear, "montrose/rule/day_of_year"
    autoload :During, "montrose/rule/during"
    autoload :Except, "montrose/rule/except"
    autoload :HourOfDay, "montrose/rule/hour_of_day"
    autoload :MinuteOfHour, "montrose/rule/minute_of_hour"
    autoload :MonthOfYear, "montrose/rule/month_of_year"
    autoload :NthDayMatcher, "montrose/rule/nth_day_matcher"
    autoload :NthDayOfMonth, "montrose/rule/nth_day_of_month"
    autoload :NthDayOfYear, "montrose/rule/nth_day_of_year"
    autoload :TimeOfDay, "montrose/rule/time_of_day"
    autoload :Total, "montrose/rule/total"
    autoload :Until, "montrose/rule/until"
    autoload :WeekOfYear, "montrose/rule/week_of_year"

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
