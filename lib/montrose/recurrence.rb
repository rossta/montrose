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
    end

    def events(opts = {})
      event_enum(opts)
    end

    def each(opts = {}, &block)
      dates(opts).each(&block)
    end

    private

    def event_enum(opts = {})
      local_opts = @options.merge(normalize_options(opts))

      @expr = []
      @expr << initialize_interval(local_opts)
      @expr << After.new(local_opts[:starts]) if local_opts[:starts]
      @expr << Before.new(local_opts[:until]) if local_opts[:until]
      @expr << MonthOfYear.new(local_opts[:month]) if local_opts[:month]

      time_enum = TimeEnumerator.new(local_opts)

      Enumerator.new do |yielder|
        loop do
          time = time_enum.next

          yielder << time if @expr.all? { |e| e.advance!(time) }
        end
      end
    end

    def initialize_interval(opts = {})
      opts = @options.merge(normalize_options(opts))
      case opts[:every]
      when :year
        Yearly.new(opts)
      when :week
        Weekly.new(opts)
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

  class TimeEnumerator
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

      @time.advance(step)
    end

    def step
      @step ||= day_step || week_step || month_step || year_step
    end

    def day_step
      if @options[:day]
        { days: 1 }
      elsif @options[:every] == :day
        { days: @interval }
      end
    end

    def week_step
      if @options[:week]
        { weeks: 1 }
      elsif @options[:every] == :week
        { weeks: @interval }
      end
    end

    def month_step
      if @options[:month]
        { months: 1 }
      elsif @options[:every] == :month
        { months: @interval }
      end
    end

    def year_step
      if @options[:year]
        { years: 1 }
      elsif @options[:every] == :year
        { years: @interval }
      end
    end
  end

  class Interval
    attr_reader :time, :starts

    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
      @repeat = opts[:repeat]
    end

    def include?(_time)
      raise "Subclass should implement"
    end

    def advance!(time)
      include?(time) && continue?
    end

    def continue?
      return true unless @repeat

      @count ||= 0
      @count += 1
      @count <= @repeat or raise StopIteration
    end
  end

  class Daily < Interval
    def include?(time)
      (time.to_date - @starts.to_date).to_i % @interval == 0
    end
  end

  class Yearly < Interval
    def include?(time)
      (time.year - @starts.year) % @interval == 0
    end
  end

  class Weekly < Interval
    def include?(time)
      ((time.to_date - base_date) / 1.week).round % @interval == 0
    end

    def base_date
      @starts.beginning_of_week.to_date
    end
  end
end
