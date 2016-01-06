module Montrose
  class Schedule
    def initialize
      @rules = []
    end

    def <<(rule)
      @rules << Montrose::Recurrence.new(rule)

      self
    end

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
