module Montrose
  class Schedule
    attr_accessor :rules

    def self.build
      schedule = new
      yield schedule if block_given?
      schedule
    end

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
      enums = @rules.map { |r| r.merge(opts).events }
      Enumerator.new do |y|
        loop do
          enums = active_enums(enums)
          enum = enums.min_by(&:peek) or break
          y << enum.next
        end
      end
    end

    private

    def active_enums(enums)
      enums.each_with_object([]) do |enum, actives|
        begin
          actives << enum if enum.peek
        rescue StopIteration
        end
      end
    end
  end
end
