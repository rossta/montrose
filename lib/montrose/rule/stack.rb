module Montrose
  module Rule
    class Stack
      def self.build(opts = {})
        stack = []
        stack << Frequency.from_options(opts)
        stack << Rule::After.new(opts[:starts]) if opts[:starts]
        stack << Rule::Before.new(opts[:until]) if opts[:until]
        stack << Rule::Total.new(opts[:total]) if opts[:total]
        stack << Rule::HourOfDay.new(opts[:hour]) if opts[:hour]
        stack << Rule::NthDayOfMonth.new(opts[:day]) if opts[:every] == :month && opts[:day].is_a?(Hash)
        stack << Rule::NthDayOfYear.new(opts[:day]) if opts[:every] == :year && opts[:day].is_a?(Hash)
        stack << Rule::DayOfWeek.new(opts[:day]) if opts[:day]
        stack << Rule::DayOfMonth.new(opts[:mday]) if opts[:mday]
        stack << Rule::DayOfYear.new(opts[:yday]) if opts[:yday]
        stack << Rule::WeekOfYear.new(opts[:week]) if opts[:week]
        stack << Rule::MonthOfYear.new(opts[:month]) if opts[:month]
        stack
      end
    end
  end
end
