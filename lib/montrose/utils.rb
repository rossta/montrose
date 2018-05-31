# frozen_string_literal: true

module Montrose
  module Utils
    module_function

    MONTHS = ::Date::MONTHNAMES

    DAYS = ::Date::DAYNAMES

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
        string = name.to_s
        MONTHS.index(string.titleize) || month_number(to_index(string))
      when 1..12
        name
      end
    end

    def month_number!(name)
      month_numbers = MONTHS.map.with_index { |_n, i| i.to_s }.slice(1, 12)
      month_number(name) or fail ConfigurationError,
        "Did not recognize month #{name}, must be one of #{(MONTHS + month_numbers).inspect}"
    end

    def day_number(name)
      case name
      when 0..6
        name
      when Symbol, String
        string = name.to_s
        DAYS.index(string.titleize) || day_number(to_index(string))
      when Array
        day_number name.first
      end
    end

    def day_number!(name)
      day_numbers = DAYS.map.with_index { |_n, i| i.to_s }
      day_number(name) or fail ConfigurationError,
        "Did not recognize day #{name}, must be one of #{(DAYS + day_numbers).inspect}"
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

    # Returns string.to_i only if string fully matches an integer
    # otherwise ensures that return value won't match a valid index
    def to_index(string)
      string =~ %r{^\d+} ? string.to_i : -1
    end
  end
end
