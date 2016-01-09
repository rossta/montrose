module Montrose
  module Rule
    def include?(_time)
      raise "Class must implement #{__method__}"
    end

    def advance!(_time)
      # default: no op
    end

    def break?
      # default: no op
    end
  end
end

require "montrose/rule/after"
require "montrose/rule/before"
require "montrose/rule/day_of_month"
require "montrose/rule/day_of_week"
require "montrose/rule/day_of_year"
require "montrose/rule/hour_of_day"
require "montrose/rule/month_of_year"
require "montrose/rule/nth_day_of_month"
require "montrose/rule/nth_day_of_year"
require "montrose/rule/stack"
require "montrose/rule/time_of_day"
require "montrose/rule/total"
require "montrose/rule/week_of_year"
