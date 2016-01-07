require "montrose/rule"
require "montrose/chainable"

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
      default_options[:starts]
    end

    private

    def event_enum(opts = {})
      local_opts = @default_options.merge(opts)
      stack = Rule::Stack.build(local_opts)
      clock = Clock.new(local_opts)

      Enumerator.new do |yielder|
        loop do
          time = clock.tick

          yes, no = stack.partition { |rule| rule.include?(time) }

          if no.empty?
            yes.each { |rule| rule.advance!(time) }
            puts time if ENV["DEBUG"]
            yielder << time
          else
            no.each(&:break?)
          end
        end
      end
    end
  end
end
