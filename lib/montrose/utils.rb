# frozen_string_literal: true

module Montrose
  module Utils
    module_function

    MONTHS = ::Date::MONTHNAMES
    MONTH_NUMBERS = { "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6,
                      "7" => 7, "8" => 8, "9" => 9, "10" => 10, "11" => 11, "12" => 12 }
    DAYS = ::Date::DAYNAMES
    DAY_NUMBERS = { "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6 }

    MAX_HOURS_IN_DAY = 24
    MAX_DAYS_IN_YEAR = 366
    MAX_WEEKS_IN_YEAR = 53
    MAX_DAYS_IN_MONTH = 31

    def as_time(time)
      return nil unless time

      if time.is_a?(String)
        parse_time(time)
      elsif time.is_a?(ActiveSupport::TimeWithZone)
        time
      elsif time.respond_to?(:to_time)
        time.to_time
      else
        Array(time).flat_map { |d| as_time(d) }
      end
    end

    def as_date(time)
      as_time(time).to_date
    end

    def parse_time(*args)
      ::Time.zone.nil? ? ::Time.parse(*args) : ::Time.zone.parse(*args)
    end

    def current_time
      ::Time.current
    end

    def month_number(name)
      case name
      when Symbol, String
        MONTHS.index(name.to_s.titleize) || MONTH_NUMBERS[name.to_s]
      when 1..12
        name
      end
    end

    def month_number!(name)
      month_number(name) or fail ConfigurationError,
        "Did not recognize month #{name}, must be one of #{(MONTHS + MONTH_NUMBERS.keys).inspect}"
    end

    def day_number(name)
      case name
      when 0..6
        name
      when Symbol, String
        DAYS.index(name.to_s.titleize) || DAY_NUMBERS[name.to_s]
      when Array
        day_number name.first
      end
    end

    def day_number!(name)
      day_number(name) or fail ConfigurationError,
        "Did not recognize day #{name}, must be one of #{(DAYS + DAY_NUMBERS.keys).inspect}"
    end

    def days_in_month(month, year = current_time.year)
      date = ::Date.new(year, month, 1)
      ((date >> 1) - date).to_i
    end

    # Returns the number of days in the given year.
    # If no year is specified, it will use the current year.
    # https://github.com/rails/rails/pull/22244
    def days_in_year(year)
      ::Montrose::Utils.days_in_month(2, year) + 337
    end
  end
end
