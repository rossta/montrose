require "montrose/rule"

module Montrose
  class Recurrence
    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    FREQUENCY = %w[hour day week month year].freeze

    # Create a hourly recurrence.
    #
    # @example
    #
    #   Recurrence.hourly
    #   Recurrence.hourly(interval: 2) #=> every 2 hours
    #   Recurrence.hourly(starts: 3.days.from_now)
    #   Recurrence.hourly(until: 10.days.from_now)
    #   Recurrence.hourly(repeat: 5)
    #   Recurrence.hourly(except: Date.tomorrow)
    #
    def self.hourly(options = {})
      new(options.merge(every: :hour))
    end

    # Create a daily recurrence.
    #
    # @example
    #
    #   Recurrence.daily
    #   Recurrence.daily(interval: 2) #=> every 2 days
    #   Recurrence.daily(starts: 3.days.from_now)
    #   Recurrence.daily(until: 10.days.from_now)
    #   Recurrence.daily(repeat: 5)
    #   Recurrence.daily(except: Date.tomorrow)
    #
    def self.daily(options = {})
      new(options.merge(every: :day))
    end

    # Create a weekly recurrence.
    #
    # @example
    #   Recurrence.weekly(on: 5) #=> 0 = sunday, 1 = monday, ...
    #   Recurrence.weekly(on: :saturday)
    #   Recurrence.weekly(on: [sunday, :saturday])
    #   Recurrence.weekly(on: :saturday, interval: 2)
    #   Recurrence.weekly(on: :saturday, repeat: 5)
    #
    def self.weekly(options = {})
      new(options.merge(every: :week))
    end

    # Create a monthly recurrence.
    #
    # @example
    #   Recurrence.monthly(on: 15) #=> every 15th day
    #   Recurrence.monthly(on: :first, weekday: :sunday)
    #   Recurrence.monthly(on: :second, weekday: :sunday)
    #   Recurrence.monthly(on: :third, weekday: :sunday)
    #   Recurrence.monthly(on: :fourth, weekday: :sunday)
    #   Recurrence.monthly(on: :fifth, weekday: :sunday)
    #   Recurrence.monthly(on: :last, weekday: :sunday)
    #   Recurrence.monthly(on: 15, interval: 2)
    #   Recurrence.monthly(on: 15, interval: :monthly)
    #   Recurrence.monthly(on: 15, interval: :bimonthly)
    #   Recurrence.monthly(on: 15, interval: :quarterly)
    #   Recurrence.monthly(on: 15, interval: :semesterly)
    #   Recurrence.monthly(on: 15, repeat: 5)
    #
    # The <tt>:on</tt> option can be one of the following:
    #
    #   * :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
    #   * :sun, :mon, :tue, :wed, :thu, :fri, :sat
    #
    def self.monthly(options = {})
      options[:every] = :month
      new(options.merge(every: :month))
    end

    # Create a yearly recurrence.
    #
    # @example
    #
    #   Recurrence.yearly(on: [7, 14]) #=> every Jul 14
    #   Recurrence.yearly(on: [7, 14], interval: 2) #=> every 2 years on Jul 14
    #   Recurrence.yearly(on: [:jan, 14], interval: 2)
    #   Recurrence.yearly(on: [:january, 14], interval: 2)
    #   Recurrence.yearly(on: [:january, 14], repeat: 5)
    #
    def self.yearly(options = {})
      new(options.merge(every: :year))
    end

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

    attr_reader :given_options, :options, :event

    def initialize(opts = {})
      @given_options = opts

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
