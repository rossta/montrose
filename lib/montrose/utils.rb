module Montrose
  module Utils
    module_function

    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    def month_number(name)
      case name
      when Symbol, String
        MONTHS.index(name.to_s.titleize) or raise "Did not recognize"
      when 1..12
        name
      else
        raise "Did not recognize month #{name}"
      end
    end

    def day_number(name)
      case name
      when Fixnum
        name
      when Symbol, String
        DAYS.index(name.to_s.titleize)
      when Array
        day_number name.first
      else
        raise "Did not recognize day #{name}"
      end
    end
  end
end
