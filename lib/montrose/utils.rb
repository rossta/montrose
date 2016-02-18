module Montrose
  module Utils
    module_function

    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    def as_time(time)
      return nil unless time

      case
      when time.is_a?(String)
        Time.parse(time)
      when time.respond_to?(:to_time)
        time.to_time
      else
        Array(time).flat_map { |d| as_time(d) }
      end
    end

    def as_date(time)
      as_time(time).to_date
    end

    def month_number(name)
      case name
      when Symbol, String
        MONTHS.index(name.to_s.titleize)
      when 1..12
        name
      end
    end

    def month_number!(name)
      month_number(name) or fail ConfigurationError,
        "Did not recognize month #{name}, must be one of #{MONTHS.inspect}"
    end

    def day_number(name)
      case name
      when 0..6
        name
      when Symbol, String
        DAYS.index(name.to_s.titleize)
      when Array
        day_number name.first
      end
    end

    def day_number!(name)
      day_number(name) or fail ConfigurationError,
        "Did not recognize day #{name}, must be one of #{DAYS.inspect}"
    end
  end
end
