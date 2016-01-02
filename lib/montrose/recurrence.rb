module Montrose
  class Recurrence
    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

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
      @expr << Total.new(local_opts[:total]) if local_opts[:total]
      @expr << initialize_day_expr(local_opts) if local_opts[:day]
      @expr << MonthOfYear.new(local_opts[:month]) if local_opts[:month]

      time_enum = TimeEnumerator.new(local_opts)

      Enumerator.new do |yielder|
        # size = 0
        loop do
          time = time_enum.next

          yes, no = @expr.partition { |e| e.include?(time) }

          if no.empty?
            yes.map { |e| e.advance!(time) }
            puts time if ENV["DEBUG"]
            yielder << time
          else
            no.map(&:break?)
          end

          # size += 1
          # raise "Too many repeats!" if size > 1_000
        end
      end
    end

    def initialize_interval(opts = {})
      case opts[:every]
      when :year
        Yearly.new(opts)
      when :week
        Weekly.new(opts)
      when :month
        Monthly.new(opts)
      when :day
        Daily.new(opts)
      else
        raise "Don't know how to enumerate every: #{opts[:every]}"
      end
    end

    def initialize_day_expr(opts = {})
      case opts[:every]
      when :month
        if opts[:day].is_a?(Hash)
          WeekDayOfMonth.new(opts[:day])
        else
          DayOfMonth.new(opts[:day])
        end
      else
        DayOfWeek.new(opts[:day])
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
      time < @end_time
    end

    def advance!(time)
    end

    def break?
      raise StopIteration
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
    end

    def break?
      raise StopIteration
    end
  end

  class Total
    def initialize(max)
      @max = max
      @count = 0
    end

    def include?(_time)
      @count <= @max
    end

    def advance!(_time)
      @count += 1
      break?
    end

    def continue?
      @count <= @max
    end

    def break?
      continue? or raise StopIteration
    end
  end

  class MonthOfYear
    def initialize(months)
      @months = [*months].compact.map { |m| month_number(m) }
    end

    def include?(time)
      @months.include?(time.month)
    end

    def advance!(time)
    end

    def break?
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

  class DayOfWeek
    def initialize(days)
      @days = [*days].compact.map { |d| day_number(d) }
    end

    def include?(time)
      @days.include?(time.wday)
    end

    def advance!(time)
    end

    def break?
    end

    private

    def day_number(name)
      case name
      when Fixnum
        name
      when Symbol, String
        Recurrence::DAYS.index(name.to_s.titleize)
      when Array
        day_number name.first
      else
        raise "Did not recognize day #{name}"
      end
    end
  end

  class WeekDayOfMonth
    def initialize(days)
      @days = day_occurrences_in_month(days)
    end

    def include?(time)
      @days.key?(time.wday) && matches_day_occurrence?(time)
    end

    def advance!(time)
    end

    def break?
    end

    private

    def matches_day_occurrence?(time)
      expected_occurrences = @days[time.wday]
      return true if expected_occurrences == :all

      this_occ, total_occ = which_occurrence_in_month(time)

      expected_occurrences.any? { |nth_occ| matches_nth_occurrence?(nth_occ, this_occ, total_occ) }
    end

    def matches_nth_occurrence?(nth_occ, this_occ, total_occ)
      return true if nth_occ == this_occ

      nth_occ < 0 && (total_occ + nth_occ + 1) == this_occ
    end

    # Return the count of the number of times wday appears in the month,
    # and which of those time falls on
    def which_occurrence_in_month(time)
      first_occurrence = ((7 - Time.utc(time.year, time.month, 1).wday) + time.wday) % 7 + 1
      this_weekday_in_month_count = ((days_in_month(time) - first_occurrence + 1) / 7.0).ceil
      nth_occurrence_of_weekday = (time.mday - first_occurrence) / 7 + 1
      [nth_occurrence_of_weekday, this_weekday_in_month_count]
    end

    # Get the days in the month for +time
    def days_in_month(time)
      date = Date.new(time.year, time.month, 1)
      ((date >> 1) - date).to_i
    end

    def day_occurrences_in_month(obj)
      case obj
      when Array
        days_in_month(Hash[obj.zip([:all].cycle)])
      when Hash
        obj.each_with_object({}) do |(name, occ), hash|
          hash[day_number(name)] = occ
        end
      end
    end

    def day_number(name)
      case name
      when Fixnum
        name
      when Symbol, String
        Recurrence::DAYS.index(name.to_s.titleize)
      when Array
        day_number name.first
      else
        raise "Did not recognize day #{name}"
      end
    end
  end

  class DayOfMonth
    def initialize(days)
      @days = [*days].compact
    end

    def include?(time)
      @days.include?(time.mday) || begin
        month_days = days_in_month(time)
        @days.any? { |d| month_days + d + 1 == time.mday }
      end
    end

    def advance!(time)
    end

    def break?
    end

    # Get the days in the month for +time
    def days_in_month(time)
      date = Date.new(time.year, time.month, 1)
      ((date >> 1) - date).to_i
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

  class Interval
    attr_reader :time, :starts

    def initialize(opts = {})
      @options = opts.dup
      @time = nil
      @count = 0
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
      @repeat = opts.fetch(:repeat, nil)
    end

    def include?(_time)
      raise "Subclass must implement"
    end

    def advance!(time)
      increment!(time)
      self.break?
    end

    def break?
      continue?(time) or raise StopIteration
    end

    def continue?(_time)
      return true unless @repeat
      @count <= @repeat
    end

    def increment!(_time)
      @count += 1
    end

    def matches_interval?(time_diff)
      time_diff.to_i % @interval == 0
    end
  end

  class Daily < Interval
    def include?(time)
      matches_interval? time.to_date - @starts.to_date
    end
  end

  class Weekly < Interval
    def include?(time)
      weeks_since_start(time) % @interval == 0
    end

    def increment!(time)
      @weeks ||= Set.new
      @weeks << weeks_since_start(time)
      @count = @weeks.count
    end

    private

    def weeks_since_start(time)
      ((time.beginning_of_week - base_date) / 1.week).round
    end

    def base_date
      @starts.beginning_of_week
    end
  end

  class Monthly < Interval
    def include?(time)
      matches_interval? time.month - @starts.month
    end
  end

  class Yearly < Interval
    def include?(time)
      matches_interval? time.year - @starts.year
    end
  end

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
end
