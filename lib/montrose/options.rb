module Montrose
  class Options
    @default_starts = nil
    @default_until = nil
    @default_every = nil

    MAX_HOURS_IN_DAY = 24
    MAX_DAYS_IN_YEAR = 366
    MAX_WEEKS_IN_YEAR = 53
    MAX_DAYS_IN_MONTH = 31

    class << self
      def new(options = {})
        return options if options.is_a?(self)
        super
      end

      def defined_options
        @defined_options ||= []
      end

      def def_option(name)
        defined_options << name.to_sym
        attr_accessor name
        protected :"#{name}="
      end

      attr_accessor :default_starts, :default_until, :default_every

      # Return the default ending time.
      #
      # @example Recurrence.default_until #=> <Date>
      #
      def default_until
        case @default_until
        when String
          Time.parse(@default_until)
        when Proc
          @default_until.call
        else
          @default_until
        end
      end

      # Return the default starting time.
      #
      # @example Recurrence.default_starts #=> <Date>
      #
      def default_starts
        case @default_starts
        when String
          Time.parse(@default_starts)
        when Proc
          @default_starts.call
        when nil
          Time.now
        else
          @default_starts
        end
      end
    end

    def_option :every
    def_option :starts
    def_option :until
    def_option :hour
    def_option :day
    def_option :mday
    def_option :yday
    def_option :week
    def_option :month
    def_option :interval
    def_option :total
    def_option :between
    def_option :at
    def_option :on

    def initialize(opts = {})
      defaults = {
        every: self.class.default_every,
        starts: self.class.default_starts,
        until: self.class.default_until,
        interval: 1,
        day: nil,
        mday: nil,
        yday: nil,
        week: nil,
        month: nil,
        total: nil
      }

      options = defaults.merge(opts)
      options.each { |(k, v)| self[k] ||= v unless v.nil? }
    end

    def to_hash
      hash_pairs = self.class.defined_options.flat_map do |opt_name|
        [opt_name, send(opt_name)]
      end
      Hash[*hash_pairs].reject { |_k, v| v.nil? }
    end

    def []=(option, val)
      send(:"#{option}=", val)
    end

    def [](option)
      send(:"#{option}")
    end

    def merge(other)
      h1 = to_hash
      h2 = other.to_hash

      self.class.new(h1.merge(h2))
    end

    def fetch(key, *args, &_block)
      fail ArgumentError, "wrong number of arguments (#{args.length} for 1..2)" if args.length > 1
      found = send(key)
      return found if found
      return args.first if args.length == 1
      fail "Key #{key.inspect} not found" unless block_given?

      yield
    end

    def key?(key)
      respond_to?(key) && !send(key).nil?
    end

    def every=(arg)
      parsed = parse_frequency(arg)

      self[:interval] = parsed[:interval] if parsed[:interval]

      @every = parsed.fetch(:every)
    end

    def starts=(time)
      @starts = as_time(time) || self.class.default_starts
    end

    def until=(time)
      @until = as_time(time) || self.class.default_until
    end

    def hour=(hours)
      @hour = map_arg(hours) { |h| assert_hour(h) }
    end

    def day=(days)
      @day = nested_map_arg(days) { |d| Montrose::Utils.day_number(d) }
    end

    def mday=(mdays)
      @mday = map_mdays(mdays)
    end

    def yday=(ydays)
      @yday = map_ydays(ydays)
    end

    def week=(weeks)
      @week = map_arg(weeks) { |w| assert_week(w) }
    end

    def month=(months)
      @month = map_arg(months) { |d| Montrose::Utils.month_number(d) }
    end

    def between=(range)
      self[:starts] = range.first
      self[:until] = range.last
    end

    def between
      return nil unless self[:starts] && self[:until]

      (self[:starts]..self[:until])
    end

    def at=(time)
      times = map_arg(time) { |t| as_time(t) }
      now = Time.now
      first = times.map { |t| t < now ? t + 24.hours : t }.min
      self[:starts] = first if first
      @at = times
    end

    def on=(arg)
      wday, mday = assert_wday_mday(arg)
      self[:day] = wday
      self[:mday] = mday if mday
      @on = arg
    end

    private

    def nested_map_arg(arg, &block)
      case arg
      when Hash
        arg.each_with_object({}) do |(k, v), hash|
          hash[yield k] = [*v]
        end
      else
        map_arg(arg, &block)
      end
    end

    def map_arg(arg, &block)
      return nil unless arg

      Array(arg).map(&block)
    end

    def map_days(arg)
      map_arg(arg) { |d| Montrose::Utils.day_number(d) }
    end

    def map_mdays(arg)
      map_arg(arg) { |d| assert_mday(d) }
    end

    def map_ydays(arg)
      map_arg(arg) { |d| assert_yday(d) }
    end

    def assert_hour(hour)
      assert_range_includes(1..MAX_HOURS_IN_DAY, hour)
    end

    def assert_mday(mday)
      assert_range_includes(1..MAX_DAYS_IN_MONTH, mday, :absolute)
    end

    def assert_yday(yday)
      assert_range_includes(1..MAX_DAYS_IN_YEAR, yday, :absolute)
    end

    def assert_week(week)
      assert_range_includes(1..MAX_WEEKS_IN_YEAR, week, :absolute)
    end

    def assert_wday_mday(arg)
      case arg
      when Hash
        [map_days(arg.keys), map_mdays(arg.values)]
      else
        map_days(arg)
      end
    end

    def assert_range_includes(range, item, absolute = false)
      test = absolute ? item.abs : item
      fail ConfigurationError, "Out of range" unless range.include?(test)

      item
    end

    def as_time(time)
      return nil unless time

      case
      when time.is_a?(String)
        Time.parse(time)
      when time.respond_to?(:to_time)
        time.to_time
      else
        Array(time).flat_map { |d| as_time(d) }
      end
    end

    def parse_frequency(input)
      if input.is_a?(Numeric)
        frequency, interval = duration_to_frequency_parts(input)
        { every: frequency, interval: interval }
      else
        { every: Frequency.assert(input) }
      end
    end

    def duration_to_frequency_parts(duration)
      parts = nil
      [:year, :month, :week, :day, :hour, :minute].each do |freq|
        div, mod = duration.divmod(1.send(freq))
        parts = [freq, div]
        return parts if mod.zero?
      end
      parts
    end
  end
end
