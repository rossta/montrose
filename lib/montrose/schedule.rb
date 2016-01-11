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
    alias_method :add, :<<

    def include?(time)
      @rules.any? { |r| r.include?(time) }
    end

    def events(opts = {})
      event_enums = @rules.map { |r| r.events(opts) }
      Enumerator.new do |y|
        loop do
          y << event_enums.min_by(&:peek).next or break
        end
      end
    end
  end
end
