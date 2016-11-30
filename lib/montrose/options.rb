module Montrose
  class Options
    include Montrose::Utils

    @default_starts = nil
    @default_until = nil
    @default_every = nil

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
          ::Montrose::Utils.parse_time(@default_until)
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
          ::Montrose::Utils.parse_time(@default_starts)
        when Proc
          @default_starts.call
        when nil
          ::Montrose::Utils.current_time
        else
          @default_starts
        end
      end

      def merge(opts = {})
        new(default_options).merge(opts)
      end

      def default_options
        {
          until: default_until,
          interval: 1
        }
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
    def_option :at
    def_option :on
    def_option :except

    def initialize(opts = {})
      defaults = {
        every: self.class.default_every,
        interval: nil,
        starts: nil,
        until: nil,
        day: nil,
        mday: nil,
        yday: nil,
        week: nil,
        month: nil,
        total: nil
      }

      options = defaults.merge(opts || {})
      options.each { |(k, v)| self[k] ||= v unless v.nil? }
    end

    def to_hash
      hash_pairs = self.class.defined_options.flat_map do |opt_name|
        [opt_name, send(opt_name)]
      end
      Hash[*hash_pairs].reject { |_k, v| v.nil? }
    end
    alias to_h to_hash

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
      @day = nested_map_arg(days) { |d| day_number!(d) }
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
      @month = map_arg(months) { |d| month_number!(d) }
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
      @at = map_arg(time) { |t| as_time_parts(t) }
    end

    def on=(arg)
      result = decompose_on_arg(arg)
      self[:day] = result[:day] if result[:day]
      self[:month] = result[:month] if result[:month]
      self[:mday] = result[:mday] if result[:mday]
      @on = arg
    end

    def except=(date)
      @except = map_arg(date) { |d| as_date(d) }
    end

    def inspect
      "#<#{self.class} #{to_h.inspect}>"
    end

    def start_time
      time = starts || default_starts

      if at
        at.map { |(hour, min)| time.change(hour: hour, min: min) }.min || time
      else
        time
      end
    end

    private

    def default_starts
      self.class.default_starts
    end

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
      map_arg(arg) { |d| day_number!(d) }
    end

    def map_mdays(arg)
      map_arg(arg) { |d| assert_mday(d) }
    end

    def map_ydays(arg)
      map_arg(arg) { |d| assert_yday(d) }
    end

    def assert_hour(hour)
      assert_range_includes(1..::Montrose::Utils::MAX_HOURS_IN_DAY, hour)
    end

    def assert_mday(mday)
      assert_range_includes(1..::Montrose::Utils::MAX_DAYS_IN_MONTH, mday, :absolute)
    end

    def assert_yday(yday)
      assert_range_includes(1..::Montrose::Utils::MAX_DAYS_IN_YEAR, yday, :absolute)
    end

    def assert_week(week)
      assert_range_includes(1..::Montrose::Utils::MAX_WEEKS_IN_YEAR, week, :absolute)
    end

    def decompose_on_arg(arg)
      case arg
      when Hash
        arg.each_with_object({}) do |(k, v), result|
          key, val = month_or_day(k)
          result[key] = val
          result[:mday] ||= []
          result[:mday] += map_mdays(v)
        end
      else
        { day: map_days(arg) }
      end
    end

    def month_or_day(key)
      month = month_number(key)
      return [:month, month] if month
      day = day_number(key)
      return [:day, day] if day
      fail ConfigurationError, "Did not recognize #{key} as a month or day"
    end

    def assert_range_includes(range, item, absolute = false)
      test = absolute ? item.abs : item
      fail ConfigurationError, "Out of range: #{range.inspect} does not include #{test}" unless range.include?(test)

      item
    end

    def as_time_parts(arg)
      return arg if arg.is_a?(Array)

      time = as_time(arg)
      [time.hour, time.min]
    end

    def parse_frequency(input)
      if input.respond_to?(:parts)
        frequency, interval = duration_to_frequency_parts(input)
        { every: frequency.to_s.singularize.to_sym, interval: interval }
      elsif input.is_a?(Numeric)
        frequency, interval = numeric_to_frequency_parts(input)
        { every: frequency, interval: interval }
      else
        { every: Frequency.assert(input) }
      end
    end

    def numeric_to_frequency_parts(number)
      parts = nil
      [:year, :month, :week, :day, :hour, :minute].each do |freq|
        div, mod = number.divmod(1.send(freq))
        parts = [freq, div]
        return parts if mod.zero?
      end
      parts
    end

    def duration_to_frequency_parts(duration)
      duration.parts.first
    end
  end
end
