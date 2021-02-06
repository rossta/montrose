module Montrose
  class Day
    extend Montrose::Utils

    NAMES = ::Date::DAYNAMES
    TWO_LETTER_ABBREVIATIONS = %w[SU MO TU WE TH FR SA].freeze
    THREE_LETTER_ABBREVIATIONS = %w[SUN MON TUE WED THU FRI SAT]
    NUMBERS = NAMES.map.with_index { |_n, i| i.to_s }

    ICAL_MATCH = /(?<ordinal>[+-]?\d+)?(?<day>[A-Z]{2})/ # e.g. 1FR

    class << self
      def parse(arg)
        case arg
        when Hash
          parse_entries(arg.entries)
        when String
          parse(arg.split(','))
        else
          parse_entries(map_arg(arg) { |value| parse_value(value) })
        end
      end

      def parse_entries(entries)
        hash = Hash.new {|h,k| h[k] = []}
        result = entries.each_with_object(hash) do |(k, v), hash|
          index = number!(k)
          hash[index] = hash[index] + [*v]
        end
        result.values.all?(&:empty?) ? result.keys : result
      end

      def parse_value(value)
        parse_ical(value) || [number!(value), nil]
      end

      def parse_ical(value)
        (match = ICAL_MATCH.match(value.to_s)) || (return nil)
        index = number!(match[:day])
        ordinal = match[:ordinal]&.to_i
        [index, ordinal]
      end

      def map_arg(arg, &block)
        return nil unless arg.present?

        Array(arg).map(&block)
      end

      def names
        NAMES
      end

      def number(name)
        case name
        when 0..6
          name
        when Symbol, String
          string = name.to_s.downcase
          NAMES.index(string.titleize) ||
            TWO_LETTER_ABBREVIATIONS.index(string.upcase) ||
            THREE_LETTER_ABBREVIATIONS.index(string.upcase) ||
            number(to_index(string))
        when Array
          number name.first
        end
      end

      def number!(name)
        number(name) || raise(ConfigurationError,
          "Did not recognize day #{name}, must be one of #{(names + abbreviations + numbers).inspect}")
      end

      def numbers
        NUMBERS
      end

      def abbreviations
        TWO_LETTER_ABBREVIATIONS + THREE_LETTER_ABBREVIATIONS
      end
    end
  end
end
