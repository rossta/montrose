module Montrose
  class Week
    class << self
      NUMBERS = (-53.upto(-1).to_a + 1.upto(53).to_a)

      def parse(arg)
        return nil unless arg.present?

        Array(arg).map { |value| assert(value.to_i) }
      end

      def assert(number)
        test = number.abs
        raise ConfigurationError, "Out of range: #{NUMBERS.inspect} does not include #{test}" unless NUMBERS.include?(number.abs)

        number
      end
    end
  end
end
