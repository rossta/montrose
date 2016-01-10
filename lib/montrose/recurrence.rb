require "montrose/chainable"
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
    end

    def initialize(opts = {})
      @default_options = Montrose::Options.new(opts)
    end

    def events(opts = {})
      event_enum(opts)
    end

    def each(opts = {})
      events(opts).each(&Proc.new)
    end

    def starts
      events.peek
    end

    private

    def event_enum(opts = {})
      local_opts = @default_options.merge(opts)
      stack = Stack.new(local_opts)
      clock = Clock.new(local_opts)

      Enumerator.new do |yielder|
        loop do
          stack.advance(clock.tick) do |time|
            yielder << time
          end
        end
      end
    end
  end
end
