module Montrose
  class Schedule
    def initialize
      @rules = []
    end

    def <<(rule)
      @rules << Montrose::Recurrence(rule)
    end

    def include?(time)
      @rules.any? { |r| r.include?(time) }
    end

    def events(opts = {})
      event_enumerators = @rules.map { |r| r.events(opts) }
      Enumerator.new do |y|
        loop do
          time = event_enumerators.min_by(&:peek).next
          if time
            y << time
          else
            break
          end
        end
      end
    end
  end
end
