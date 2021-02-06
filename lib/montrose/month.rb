module Montrose
  class Month
    extend Montrose::Utils

    NAMES = ::Date::MONTHNAMES # starts with nil to match 1-12 numbering
    NUMBERS = NAMES.map.with_index { |_n, i| i.to_s }.slice(1, 12)

    class << self
      def parse(value)
        case value
        when String
          parse(value.split(",").compact)
        when Array
          value.map { |m|
            Montrose::Month.number!(m)
          }.presence
        else
          parse(Array(value))
        end
      end

      def names
        NAMES
      end

      def numbers
        NUMBERS
      end

      def number(name)
        case name
        when Symbol, String
          string = name.to_s
          NAMES.index(string.titleize) || number(to_index(string))
        when 1..12
          name
        end
      end

      def number!(name)
        numbers = NAMES.map.with_index { |_n, i| i.to_s }.slice(1, 12)
        number(name) || raise(ConfigurationError,
          "Did not recognize month #{name}, must be one of #{(NAMES + numbers).inspect}")
      end
    end
  end
end
