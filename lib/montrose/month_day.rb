module Montrose
  class MonthDay
    class << self
      MDAYS = (-31.upto(-1) + 1.upto(31)).to_a

      def parse(mdays)
        return nil unless mdays.present?

        case mdays
        when String
          parse(mdays.split(","))
        else
          Array(mdays).map { |d| assert(d.to_i) }
        end
      end

      def assert(number)
        test = number.abs
        raise ConfigurationError, "Out of range: #{MDAYS.inspect} does not include #{test}" unless MDAYS.include?(number.abs)

        number
      end
    end
  end
end
