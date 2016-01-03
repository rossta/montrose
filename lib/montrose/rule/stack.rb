module Montrose
  module Rule
    class Stack
      def self.build(opts = {})
        stack = []
        stack << Frequency.from_options(opts)
        stack << Rule::After.new(opts[:starts]) if opts[:starts]
        stack << Rule::Before.new(opts[:until]) if opts[:until]
        stack << Rule::Total.new(opts[:total]) if opts[:total]
        stack << initialize_day_expr(opts) if opts[:day]
        stack << Rule::DayOfMonth.new(opts[:mday]) if opts[:mday]
        stack << Rule::DayOfYear.new(opts[:yday]) if opts[:yday]
        stack << Rule::WeekOfYear.new(opts[:week]) if opts[:week]
        stack << Rule::MonthOfYear.new(opts[:month]) if opts[:month]
        stack << Rule::HourOfDay.new(opts[:hour]) if opts[:hour]
        stack
      end

      def self.initialize_day_expr(opts = {})
        case
        when opts[:every] == :month && opts[:day].is_a?(Hash)
          Rule::NthDayOfMonth.new(opts[:day])
        when opts[:every] == :year && opts[:day].is_a?(Hash)
          Rule::NthDayOfYear.new(opts[:day])
        else
          Rule::DayOfWeek.new(opts[:day])
        end
      end
    end
  end
end
