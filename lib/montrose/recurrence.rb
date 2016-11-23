require "json"
require "montrose/chainable"
require "montrose/errors"
require "montrose/stack"
require "montrose/clock"

module Montrose
  class Recurrence
    extend Forwardable
    include Chainable
    include Enumerable

    attr_reader :default_options
    def_delegator :@default_options, :total, :length
    def_delegator :@default_options, :starts, :starts_at
    def_delegator :@default_options, :until, :ends_at

    class << self
      def new(options = {})
        return options if options.is_a?(self)
        super
      end

      def dump(obj)
        return nil if obj.nil?
        unless obj.is_a?(self)
          fail SerializationError,
            "Object was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
        end

        JSON.dump(obj.to_hash)
      end

      def load(json)
        new JSON.parse(json)
      end
    end

    def initialize(opts = {})
      @default_options = Montrose::Options.new(opts)
    end

    # Returns an enumerator for iterating over
    # timestamps in the recurrence
    #
    # @example
    #   recurrence.events
    #
    # @return [Enumerator] a enumerator of recurrence timestamps
    #
    def events
      event_enum
    end

    def each(&block)
      events.each(&block)
    end

    # Returns a hash of the options used to create
    # the recurrence
    #
    # @return [Hash] hash of recurrence options
    #
    def to_hash
      default_options.to_hash
    end
    alias to_h to_hash

    # Returns json string of options used to create
    # the recurrence
    #
    # @return [String] json of recurrence options
    #
    def to_json
      to_hash.to_json
    end

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{to_h.inspect}>"
    end

    # Return true/false if given timestamp equals a
    # timestamp given by the recurrence
    #
    # @return [Boolean] timestamp is included in recurrence
    #
    def include?(timestamp)
      return false if earlier?(timestamp) || later?(timestamp)

      recurrence = finite? ? self : starts(timestamp)

      recurrence.events.lazy.each do |event|
        return true if event == timestamp
        return false if event > timestamp
      end or false
    end

    # Return true/false if given timestamp equals
    def finite?
      ends_at || length
    end

    def earlier?(timestamp)
      starts_at && timestamp < starts_at
    end

    def later?(timestamp)
      ends_at && timestamp > ends_at
    end

    private

    def event_enum
      opts = Options.merge(@default_options)
      stack = Stack.new(opts)
      clock = Clock.new(opts)

      Enumerator.new do |yielder|
        loop do
          stack.advance(clock.tick) do |time|
            yielder << time
          end or break
        end
      end
    end
  end
end
