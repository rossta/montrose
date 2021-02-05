# frozen_string_literal: true

module Montrose
  module Utils
    module_function

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

    # Recurrence at fractions of a second are not recognized
    def normalize_time(time)
      time&.change(usec: 0)
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
      /^\d+/.match?(string) ? string.to_i : -1
    end
  end
end
