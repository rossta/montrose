require "montrose/rule"

module Montrose
  # Maintains stack of recurrences rules that apply to
  # an associated recurrence; manages advancing state
  # on each rule in stack as time instances are iterated.
  #
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

    def initialize(opts = {})
      @stack = self.class.build(opts)
    end

    # Given a time instance, advances state of when all
    # recurrence rules on the stack match, and yielding
    # time to the block, otherwise, invokes break? on
    # non-matching rules.
    #
    # @param [Time] time - time instance candidate for recurrence
    #
    def advance(time)
      yes, no = @stack.partition { |rule| rule.include?(time) }

      if no.empty?
        yes.each { |rule| rule.advance!(time) }
        puts time if ENV["DEBUG"]
        yield time if block_given?
      else
        no.each(&:break?)
      end
    end
  end
end
