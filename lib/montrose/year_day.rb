module Montrose
  class YearDay
    class << self
      YDAYS = (1.upto(366)).to_a

      def parse(ydays)
        return nil unless ydays.present?

        case ydays
        when String
          parse(ydays.split(","))
        else
          Array(ydays).map { |d| assert(d.to_i) }
        end
      end

      def assert(number)
        test = number.abs
        raise ConfigurationError, "Out of range: #{YDAYS.inspect} does not include #{test}" unless YDAYS.include?(number.abs)

        number
      end
    end
  end
end
