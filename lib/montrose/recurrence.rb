require "montrose/rule"
require "montrose/chainable"

module Montrose
  class Recurrence
    include Chainable

    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    # Return the default starting time.
    #
    # @example Recurrence.default_starts_time #=> <Date>
    #
    def self.default_starts_time
      case @default_starts_time
      when Proc
        @default_starts_time.call
      else
        Time.now
      end
    end

    # Set the default starting time globally.
    #
    # @example Can be a proc or a string.
    #
    #   Recurrence.default_starts_time = proc { Date.today }
    #
    def self.default_starts_time=(time)
      unless time.respond_to?(:call) || Time.respond_to?(time.to_s) || time.nil?
        fail ArgumentError, 'default_starts_time must be a proc or an evaluatable string such as "Date.current"'
      end

      @default_starts_time = time
    end

    attr_reader :default_options, :options, :event

    def initialize(opts = {})
      @default_options = opts

      options = opts.dup
      options[:starts] ||= self.class.default_starts_time
      options[:interval] ||= 1

      @options = normalize_options(options)
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
      local_opts = @options.merge(normalize_options(opts))
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

    def normalize_options(opts = {})
      options = opts.dup

      [:starts, :until, :except].
        select { |k| options.key?(k) }.
        each { |k| options[k] = as_time(options[k]) }

      options
    end

    def as_time(time) # :nodoc:
      case
      when time.respond_to?(:to_time)
        time.to_time
      when time.is_a?(String)
        Time.parse(time)
      when time.is_a?(Array)
        [time].compact.flat_map { |d| as_time(d) }
      else
        time
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
