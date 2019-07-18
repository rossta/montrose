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

    class << self
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
      def build
        schedule = new
        yield schedule if block_given?
        schedule
      end

      def dump(obj)
        return nil if obj.nil?
        return dump(load(obj)) if obj.is_a?(String)

        array = case obj
                when Array
                  new(obj).to_a
                when self
                  obj.to_a
                else
                  fail SerializationError,
                    "Object was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
                end

        JSON.dump(array)
      end

      def load(json)
        return nil if json.blank?

        new JSON.parse(json)
      rescue JSON::ParserError => e
        fail SerializationError, "Could not parse JSON: #{e}"
      end
    end

    def initialize(rules = [])
      @rules = rules.map { |rule| Montrose::Recurrence.new(rule) }
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

    def to_a
      @rules.map(&:to_hash)
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
