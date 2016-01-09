module Montrose
  module Rule
    class Stack
      def self.build(opts = {})
        [
          Frequency,
          Rule::After,
          Rule::Before,
          Rule::Total,
          Rule::TimeOfDay,
          Rule::HourOfDay,
          Rule::NthDayOfMonth,
          Rule::NthDayOfYear,
          Rule::DayOfWeek,
          Rule::DayOfMonth,
          Rule::DayOfYear,
          Rule::WeekOfYear,
          Rule::MonthOfYear
        ].map { |r| r.from_options(opts) }.compact
      end
    end
  end
end
