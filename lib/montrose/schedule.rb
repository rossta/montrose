module Montrose
  class Schedule
    attr_accessor :rules

    def initialize
      @rules = []
    end

    def <<(rule)
      @rules << Montrose::Recurrence.new(rule)

      self
    end
    alias add <<

    def include?(time)
      @rules.any? { |r| r.include?(time) }
    end

    def events(opts = {})
      rules = @rules.map { |r| r.merge(opts) }
      Enumerator.new do |y|
        loop do
          rule = rules.select(&:active?).min_by(&:peek) or break
          y << rule.next
        end
      end
    end
  end
end
