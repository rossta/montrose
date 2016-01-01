module Montrose
  class Recurrence
    MONTHS = Date::MONTHNAMES

    FREQUENCY = %w[day week month year].freeze
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

    # Return the default ending time. Defaults to 2037-12-31.
    #
    # @example Recurrence.default_until_time
    #
    def self.default_until_time
      @default_until_time ||= Date.new(2037, 12, 31)
    end

    # Set the default ending time globally.
    # Can be a time or a string recognized by Date#parse.
    #
    # @example Recurrence.default_until_time = "2012-12-31"
    # @example Recurrence.default_until_time = Date.tomorrow
    #
    def self.default_until_time=(time)
      @default_until_time = as_time(time)
    end

    attr_reader :given_options, :options, :event

    def initialize(opts = {})
      @given_options = opts

      options = opts.dup
      options[:starts] ||= self.class.default_starts_time
      options[:interval] ||= 1

      @options = normalize_options(options)

      @event = initialize_event
    end

    def events(opts = {})
      event_enum(opts)
    end

    def each(opts = {}, &block)
      dates(opts).each(&block)
    end

    private

    def event_enum(opts = {})
      @event = initialize_event(opts)

      local_opts = @options.merge(opts)

      @expr = []
      @expr << After.new(as_time(local_opts[:starts])) if local_opts[:starts]
      @expr << Before.new(as_time(local_opts[:until])) if local_opts[:until]
      @expr << MonthOfYear.new(local_opts[:month]) if local_opts[:month]
      @expr << Count.new(local_opts[:repeat]) if local_opts[:repeat]

      Enumerator.new do |yielder|
        loop do
          time = @event.next

          if @expr.all? { |e| e.advance!(time) }
            yielder << time
          end
        end
      end
    end

    def temporal_expressions_include?(time, opts = {})
      (opts[:starts].nil? || time >= opts[:starts]) &&
        (opts[:until].nil? || time <= opts[:until]) &&
        (opts[:except].nil? || !opts[:except].include?(time))
    end

    def initialize_event(opts = {})
      opts = @options.merge(normalize_options(opts))
      case opts[:every]
      when :day
        Daily.new(opts)
      else
        raise "Don't know how to enumerate every: #{opts[:every]}"
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

  class Before
    def initialize(end_time)
      @end_time = end_time
    end

    def include?(time)
      time <= @end_time
    end

    def advance!(time)
      include?(time) or raise StopIteration
    end
  end

  class After
    def initialize(start_time)
      @start_time = start_time
    end

    def include?(time)
      time >= @start_time
    end

    def advance!(time)
      include?(time) or raise StopIteration
    end
  end

  class Count
    def initialize(max)
      @max = max
      @current = 0
    end

    def include?(_)
      @current <= @max
    end

    def advance!(_)
      @current += 1
      include?(_) or raise StopIteration
    end
  end

  class MonthOfYear
    def initialize(months)
      @months = [months].compact.map { |m| month_number(m) }
    end

    def include?(time)
      @months.include?(time.month)
    end

    def advance!(time)
      include?(time)
    end

    private

    def month_number(name)
      case name
      when Fixnum
        name
      when Symbol, String
        Recurrence::MONTHS.index(name.to_s.titleize)
      else
        raise "Did not recognize month #{name}"
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

  class Daily
    attr_reader :time, :starts

    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
    end

    def next
      @time = peek
    end

    def peek
      return @time = @starts if @time.nil?

      @time.advance(days: @interval)
    end
  end
end
