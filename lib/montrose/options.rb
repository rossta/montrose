module Montrose
  class Options
    @default_starts_time = nil
    @default_ends_time = nil

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

      # Set the default starting time globally.
      #
      # @example Can be a proc or a string.
      #
      #   Recurrence.default_starts_time = proc { Date.today }
      #
      def default_ends_time=(time)
        unless time.respond_to?(:call) || Time.respond_to?(time.to_s) || time.nil?
          fail ArgumentError, 'default_ends_time must be a proc or an evaluatable string such as "Date.current"'
        end

        @default_ends_time = time
      end

      # Return the default ending time.
      #
      # @example Recurrence.default_ends_time #=> <Date>
      #
      def default_ends_time
        case @default_ends_time
        when Proc
          @default_ends_time.call
        else
          Time.now
        end
      end

      # Return the default starting time.
      #
      # @example Recurrence.default_starts_time #=> <Date>
      #
      def default_starts_time
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
      def default_starts_time=(time)
        unless time.respond_to?(:call) || Time.respond_to?(time.to_s) || time.nil?
          fail ArgumentError, 'default_starts_time must be a proc or an evaluatable string such as "Date.current"'
        end

        @default_starts_time = time
      end
    end

    def_option :every
    def_option :starts
    def_option :until
    def_option :day
    def_option :mday
    def_option :yday
    def_option :week
    def_option :month
    def_option :interval
    def_option :total

    def initialize(opts = {})
      defaults = {
        every: nil,
        starts: self.class.default_starts_time,
        until: self.class.default_ends_time,
        day: nil,
        mday: nil,
        yday: nil,
        week: nil,
        month: nil,
        interval: 1,
        total: nil
      }

      options = defaults.merge(opts)
      options.each { |(k, v)| self[k] = v }
    end

    def to_hash
      hash_pairs = self.class.defined_options.flat_map do |opt_name|
        [opt_name, send(opt_name)]
      end
      Hash[*hash_pairs]
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

    def fetch(key, default_val = nil, &block)
      instance_variable_get("@#{key}") || default_val || block.call
    end

    def every=(frequency)
      raise "Please specify the :every option" unless frequency

      @every = Frequency.assert(frequency)
    end

    def day=(days)
      @day = map(days) { |d| Montrose::Utils.day_number(d) }
    end

    def mday=(mdays)
      @mday = map(mdays) { |d| assert_range_includes(1..31, d) }
    end

    def yday=(ydays)
      @yday = map(ydays) { |d| assert_range_includes(1..366, d) }
    end

    def month=(months)
      @month = map(months) { |d| Montrose::Utils.month_number(d) }
    end

    def map(arg, &block)
      return nil unless arg

      array = case arg
              when Range
                arg.to_a
              else
                [*arg]
              end

      array.map(&block)
    end

    def assert_range_includes(range, item)
      raise "Out of range" unless range.include?(item.abs)

      item
    end
  end
end
