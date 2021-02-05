module Montrose
  class Month
    extend Montrose::Utils

    NAMES = ::Date::MONTHNAMES # starts with nil to match 1-12 numbering

    def self.names
      NAMES
    end

    def self.numbers
      @numbers ||= NAMES.map.with_index { |_n, i| i.to_s }.slice(1, 12)
    end

    def self.number(name)
      case name
      when Symbol, String
        string = name.to_s
        NAMES.index(string.titleize) || number(to_index(string))
      when 1..12
        name
      end
    end

    def self.number!(name)
      numbers = NAMES.map.with_index { |_n, i| i.to_s }.slice(1, 12)
      number(name) || raise(ConfigurationError,
        "Did not recognize month #{name}, must be one of #{(NAMES + numbers).inspect}")
    end
  end
end
