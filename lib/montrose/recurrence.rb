require "montrose/rule"
require "montrose/chainable"

module Montrose
  class Recurrence
    include Chainable

    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    attr_reader :default_options, :options, :event

    def initialize(opts = {})
      @default_options = Montrose::Options.new(opts)

      @options = @default_options
    end

    def events(opts = {})
      event_enum(opts)
    end

    def each(opts = {}, &block)
      events(opts).each(&block)
    end

    def starts
      options[:starts]
    end

    def next
      events.next
    end

    private

    def event_enum(opts = {})
      local_opts = @options.merge(opts)
      stack = Rule::Stack.build(local_opts)
      clock = Clock.new(local_opts)

      Enumerator.new do |yielder|
        loop do
          time = clock.tick

          yes, no = stack.partition { |rule| rule.include?(time) }

          if no.empty?
            yes.map { |rule| rule.advance!(time) }
            puts time if ENV["DEBUG"]
            yielder << time
          else
            no.map(&:break?)
          end
        end
      end
    end
  end

  def Recurrence(obj)
    case obj
    when Recurrence
      obj
    else
      Recurrence.new(obj)
    end
  end

  module_function :Recurrence
end
