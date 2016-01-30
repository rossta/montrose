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
          enum = active_enums(enums).min_by(&:peek) or break
          y << enum.next
        end
      end
    end

    private

    def active_enums(enums)
      enums.select do |e|
        begin
          e.peek
        rescue StopIteration
          false
        end
      end
    end
  end
end
