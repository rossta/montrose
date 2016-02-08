require "json"
require "montrose/chainable"
require "montrose/errors"
require "montrose/stack"
require "montrose/clock"

module Montrose
  class Recurrence
    include Chainable
    include Enumerable

    attr_reader :default_options

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
        new JSON.load(json)
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

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{to_h.inspect}>"
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
