module Montrose
  class Recurrence
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

    def initialize(options = {})
      @given_options = options
      @options = options.dup

      @options[:interval] ||= 1
      @options[:starts]   = as_time(@options.fetch(:starts) { self.class.default_starts_time })
      @options[:until]    = as_time(@options.fetch(:until) { self.class.default_until_time })
      @options[:through]  = as_time(options[:through])
      @options[:except]   = [options[:except]].compact.flat_map { |d| as_time(d) }

      @event = initialize_event(@options)
    end

    def events(opts = {})
      @event.reset(opts)
      event_enum(opts)
    end

    def each(opts = {}, &block)
      dates(opts).each(&block)
    end

    # Return the next time in recurrence, and changes the internal time object.
    #
    #   r = Recurrence.weekly(on: :sunday, starts: "2010-11-15")
    #   r.next #=> Sun, 21 Nov 2010
    #   r.next #=> Sun, 28 Nov 2010
    #
    def next
      @event.next
    end

    # Reset the recurrence cache, returning to the first available time.
    def reset!
      @event.reset!
      @events = nil
    end

  private

    def event_enum(opts = {})
      local_opts = @options.merge(opts)

      local_opts[:starts]  = as_time(local_opts[:starts])
      local_opts[:until]   = as_time(local_opts[:until])
      local_opts[:through] = as_time(local_opts[:through])

      Enumerator.new do |yielder|
        size = 0
        loop do
          time = self.next

          break unless time

          valid_start = local_opts[:starts].nil? || time >= local_opts[:starts]
          valid_until = local_opts[:until].nil? || time <= local_opts[:until]
          valid_except = local_opts[:except].nil? || !local_opts[:except].include?(time)

          if valid_start && valid_until && valid_except
            yielder << time
            size += 1
          end

          stop_repeat = local_opts[:repeat] && size == local_opts[:repeat]
          stop_until = local_opts[:until] && local_opts[:until] <= time
          stop_through = local_opts[:through] && local_opts[:through] <= time

          break if stop_until || stop_repeat || stop_through
        end
      end
    end

    def initialize_event(options)
      # {
      #   day: Daily,
      #   week: Weekly,
      #   month: Monthly,
      #   year: Yearly
      # }.fetch(options[:every].to_sym).new(options)

      Daily.new(options)
    end

    def as_time(time) # :nodoc:
      case
        when time.respond_to?(:to_time)
        time.to_time
        when time.is_a?(String)
        Time.parse(time)
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

  class Daily
    attr_reader :time, :starts

    def initialize(opts = {})
      @options = opts.dup
      opts.fetch(:starts)
      reset(@options)
    end

    def reset(opts = {})
      @time = nil
      @starts = opts.fetch(:starts, @starts)
      @interval = opts.fetch(:interval, 1)
    end

    def next
      return nil if finished?
      return @time = @starts if @time.nil?

      time = peek

      @finished = true if @options[:through] && time >= @options[:through]

      if @time > @options[:until]
        @finished = true
        return nil
      end

      @time = time
    end

    def peek
      @time + step
    end

    def step
      @interval.days
    end

    def finished?
      @finished
    end
  end
end
