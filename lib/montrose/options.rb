# frozen_string_literal: true

require "montrose/time_of_day"

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

      attr_accessor :default_every
      attr_writer :default_starts, :default_until

      # Return the default ending time.
      #
      # @example Recurrence.default_until #=> <Date>
      #
      def default_until
        ::Montrose::Utils.normalize_time determine_default_until
      end

      # private
      def determine_default_until
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
        ::Montrose::Utils.normalize_time determine_default_starts
      end

      # private
      def determine_default_starts
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
    def_option :between
    def_option :covering
    def_option :during
    def_option :minute
    def_option :hour
    def_option :day
    def_option :mday
    def_option :yday
    def_option :week
    def_option :week_start
    def_option :month
    def_option :interval
    def_option :total
    def_option :at
    def_option :on
    def_option :except
    def_option :exclude_end

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
        total: nil,
        week_start: nil,
        exclude_end: nil
      }

      options = defaults.merge(opts || {})
      options.each { |(k, v)| self[k] ||= v unless v.nil? }
    end

    def to_hash
      hash_pairs = self.class.defined_options.flat_map { |opt_name|
        [opt_name, send(opt_name)]
      }
      Hash[*hash_pairs].reject { |_k, v| v.nil? }
    end
    alias_method :to_h, :to_hash

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

    def fetch(key, *args)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 1..2)" if args.length > 1

      found = send(key)
      return found if found
      return args.first if args.length == 1
      raise "Key #{key.inspect} not found" unless block

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

    alias_method :frequency, :every
    alias_method :frequency=, :every=

    def starts=(time)
      @starts = normalize_time(as_time(time)) || default_starts
    end

    def until=(time)
      @until = normalize_time(as_time(time)) || default_until
    end

    def minute=(minutes)
      @minute = Minute.parse(minutes)
    end

    def hour=(hours)
      @hour = map_arg(hours) { |h| assert_hour(h) }
    end

    def during=(during_arg)
      @during = decompose_during_arg(during_arg)
        .each_with_object([]) { |(time_of_day_first, time_of_day_last), all|
        if time_of_day_last < time_of_day_first
          all.push(
            [time_of_day_first.parts, end_of_day.parts],
            [beginning_of_day.parts, time_of_day_last.parts]
          )
        else
          all.push([time_of_day_first.parts, time_of_day_last.parts])
        end
      }.presence
    end

    def day=(days)
      @day = Day.parse(days)
    end

    def mday=(mdays)
      @mday = MonthDay.parse(mdays)
    end

    def yday=(ydays)
      @yday = YearDay.parse(ydays)
    end

    def week=(weeks)
      @week = Week.parse(weeks)
    end

    def month=(months)
      @month = Month.parse(months)
    end

    def between=(range)
      if Montrose.enable_deprecated_between_masking?
        @covering = range
      end
      self[:starts] = range.first unless self[:starts]
      self[:until] = range.last unless self[:until]
    end

    def at=(time)
      @at = map_arg(time) { |t| time_of_day_parse(t).parts }
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
        at.map { |hour, min, sec = 0| time.change(hour: hour, min: min, sec: sec) }
          .select { |t| t >= time }
          .min || time
      else
        time
      end
    end

    private

    def default_starts
      self.class.default_starts
    end

    def default_until
      self.class.default_until
    end

    def map_arg(arg, &block)
      return nil unless arg

      Array(arg).map(&block)
    end

    def assert_hour(hour)
      assert_range_includes(1..::Montrose::Utils::MAX_HOURS_IN_DAY, hour)
    end

    def decompose_on_arg(arg)
      case arg
      when Hash
        arg.each_with_object({}) do |(k, v), result|
          key, val = month_or_day(k)
          result[key] = val
          result[:mday] ||= []
          result[:mday] += Montrose::MonthDay.parse(v)
        end
      else
        {day: Montrose::Day.parse(arg)}
      end
    end

    def month_or_day(key)
      month = Montrose::Month.number(key)
      return [:month, month] if month

      day = Montrose::Day.number(key)
      return [:day, day] if day

      raise ConfigurationError, "Did not recognize #{key} as a month or day"
    end

    def assert_range_includes(range, item, absolute = false)
      test = absolute ? item.abs : item
      raise ConfigurationError, "Out of range: #{range.inspect} does not include #{test}" unless range.include?(test)

      item
    end

    def parse_frequency(input)
      if input.respond_to?(:parts)
        frequency, interval = duration_to_frequency_parts(input)
        {every: frequency.to_s.singularize.to_sym, interval: interval}
      elsif input.is_a?(Numeric)
        frequency, interval = numeric_to_frequency_parts(input)
        {every: frequency, interval: interval}
      else
        {every: Frequency.assert(input)}
      end
    end

    def numeric_to_frequency_parts(number)
      parts = nil
      %i[year month week day hour minute].each do |freq|
        div, mod = number.divmod(1.send(freq))
        parts = [freq, div]
        return parts if mod.zero?
      end
      parts
    end

    def duration_to_frequency_parts(duration)
      duration.parts.first
    end

    def decompose_during_arg(during_arg)
      case during_arg
      when Range
        [decompose_during_parts(during_arg)]
      else
        map_arg(during_arg) { |d| decompose_during_parts(d) } || []
      end
    end

    def decompose_during_parts(during_parts)
      case during_parts
      when Range
        decompose_during_parts([during_parts.first, during_parts.last])
      when String
        decompose_during_parts(during_parts.split(/[-—–]/))
      else
        during_parts.map { |parts| time_of_day_parse(parts) }
      end
    end

    def time_of_day_parse(time_parts)
      ::Montrose::TimeOfDay.parse(time_parts)
    end

    def end_of_day
      @end_of_day ||= time_of_day_parse(Time.now.end_of_day)
    end

    def beginning_of_day
      @beginning_of_day ||= time_of_day_parse(Time.now.beginning_of_day)
    end
  end
end
