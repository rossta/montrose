module Montrose
  class Hour
    HOURS_IN_DAY = 1.upto(24).to_a.freeze

    class << self
      def parse(arg)
        case arg
        when String
          parse(arg.split(","))
        else
          Array(arg).map { |h| assert(h.to_i) }.presence
        end
      end

      def assert(hour)
        raise ConfigurationError, "Out of range: #{HOURS_IN_DAY.inspect} does not include #{hour}" unless HOURS_IN_DAY.include?(hour)

        hour
      end
    end
  end
end
