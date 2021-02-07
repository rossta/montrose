module Montrose
  class Minute
    MINUTES_IN_HOUR = 0.upto(59).to_a.freeze

    class << self
      def parse(arg)
        case arg
        when String
          parse(arg.split(","))
        else
          Array(arg).map { |m| assert(m.to_i) }.presence
        end
      end

      def assert(minute)
        raise ConfigurationError, "Out of range: #{MINUTES_IN_HOUR.inspect} does not include #{minute}" unless MINUTES_IN_HOUR.include?(minute)

        minute
      end
    end
  end
end
