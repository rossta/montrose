module Montrose
  class Day
    extend Montrose::Utils

    NAMES = ::Date::DAYNAMES
    ABBREVIATIONS = %w[SU MO TU WE TH FR SA].freeze

    def self.names
      NAMES
    end

    def self.number(name)
      case name
      when 0..6
        name
      when Symbol, String
        string = name.to_s
        NAMES.index(string.titleize) ||
          ABBREVIATIONS.index(string.upcase) ||
          number(to_index(string))
      when Array
        number name.first
      end
    end

    def self.number!(name)
      numbers = NAMES.map.with_index { |_n, i| i.to_s }
      number(name) || raise(ConfigurationError,
        "Did not recognize day #{name}, must be one of #{(NAMES + numbers).inspect}")
    end
  end
end
