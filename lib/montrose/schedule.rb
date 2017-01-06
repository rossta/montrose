# frozen_string_literal: true
module Montrose
  # A schedule represents a group of recurrences
  #
  # @author Ross Kaffenberger
  # @since 0.0.1
  # @attr_reader [Array] rules the list of recurrences
  #
  class Schedule
    attr_accessor :rules

    # Instantiates a schedule and yields the instance to an optional
    # block for building recurrences inline
    #
    # @example Build a schedule with multiple rules added in the given block
    #   schedule = Montrose::Schedule.build do |s|
    #     s << { every: :day }
    #     s << { every: :year }
    #   end
    #
    # @return [Montrose::Schedule]
    #
    def self.build
      schedule = new
      yield schedule if block_given?
      schedule
    end

    def initialize
      @rules = []
    end

    # Add a recurrence rule to the schedule, either by hash or recurrence
    # instance
    #
    # @example Add a recurrence by hash
    #   schedule = Montrose::Schedule.new
    #   schedule << { every: :day }
    #
    # @example Add a recurrence by instance
    #   schedule = Montrose::Schedule.new
    #   recurrence = Montrose.recurrence(every: :day)
    #   schedule << recurrence
    #
    def <<(rule)
      @rules << Montrose::Recurrence.new(rule)

      self
    end
    alias add <<

    # Return true/false if given timestamp is included in any of the rules
    # found in the schedule
    #
    # @return [Boolean] whether or not timestamp is included in schedule
    #
    def include?(timestamp)
      @rules.any? { |r| r.include?(timestamp) }
    end

    # Returns an enumerator for iterating over timestamps in the schedule
    #
    # @example Return the events
    #   schedule = Montrose::Schedule.build do |s|
    #     s << { every: :day }
    #   end
    #   schedule.events
    #
    # @return [Enumerator] an enumerator of recurrence timestamps
    #
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
