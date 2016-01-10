require "montrose/options"

module Montrose
  module Chainable
    # Create a recurrence from the given frequency
    # @example
    #
    #   Montrose.every(:hour)
    #   Montrose.every(:hour, interval: 2) #=> every 2 hours
    #   Montrose.every(3.days, starts: 2.days.from_now) #=> every 3 days
    #   Montrose.every(1.year, until: 10.days.from_now)
    #
    def every(frequency, options = {})
      branch options.merge(every: frequency)
    end

    # Create a minutely recurrence.
    #
    # @example
    #
    #   Montrose.minutely
    #   Montrose.minutely(interval: 2) #=> every 2 minutes
    #   Montrose.minutely(starts: 3.days.from_now)
    #   Montrose.minutely(until: 10.days.from_now)
    #   Montrose.minutely(total: 5)
    #   Montrose.minutely(except: Date.tomorrow)
    #
    def minutely(options = {})
      branch options.merge(every: :minute)
    end

    # Create a hourly recurrence.
    #
    # @example
    #
    #   Montrose.hourly
    #   Montrose.hourly(interval: 2) #=> every 2 hours
    #   Montrose.hourly(starts: 3.days.from_now)
    #   Montrose.hourly(until: 10.days.from_now)
    #   Montrose.hourly(total: 5)
    #   Montrose.hourly(except: Date.tomorrow)
    #
    def hourly(options = {})
      branch options.merge(every: :hour)
    end

    # Create a daily recurrence.
    #
    # @example
    #
    #   Recurrence.daily
    #   Recurrence.daily(interval: 2) #=> every 2 days
    #   Recurrence.daily(starts: 3.days.from_now)
    #   Recurrence.daily(until: 10.days.from_now)
    #   Recurrence.daily(total: 5)
    #   Recurrence.daily(except: Date.tomorrow)
    #
    def daily(options = {})
      branch options.merge(every: :day)
    end

    # Create a weekly recurrence.
    #
    # @example
    #   Recurrence.weekly(on: 5) #=> 0 = sunday, 1 = monday, ...
    #   Recurrence.weekly(on: :saturday)
    #   Recurrence.weekly(on: [sunday, :saturday])
    #   Recurrence.weekly(on: :saturday, interval: 2)
    #   Recurrence.weekly(on: :saturday, total: 5)
    #
    def weekly(options = {})
      branch options.merge(every: :week)
    end

    # Create a monthly recurrence.
    #
    # @example
    #   Recurrence.monthly(on: 15) #=> every 15th day
    #   Recurrence.monthly(on: :first, weekday: :sunday)
    #   Recurrence.monthly(on: :second, weekday: :sunday)
    #   Recurrence.monthly(on: :third, weekday: :sunday)
    #   Recurrence.monthly(on: :fourth, weekday: :sunday)
    #   Recurrence.monthly(on: :fifth, weekday: :sunday)
    #   Recurrence.monthly(on: :last, weekday: :sunday)
    #   Recurrence.monthly(on: 15, interval: 2)
    #   Recurrence.monthly(on: 15, interval: :monthly)
    #   Recurrence.monthly(on: 15, interval: :bimonthly)
    #   Recurrence.monthly(on: 15, interval: :quarterly)
    #   Recurrence.monthly(on: 15, interval: :semesterly)
    #   Recurrence.monthly(on: 15, total: 5)
    #
    # The <tt>:on</tt> option can be one of the following:
    #
    #   * :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
    #
    def monthly(options = {})
      branch options.merge(every: :month)
    end

    # Create a yearly recurrence.
    #
    # @example
    #
    #   Recurrence.yearly(on: [7, 14]) #=> every Jul 14
    #   Recurrence.yearly(on: [7, 14], interval: 2) #=> every 2 years on Jul 14
    #   Recurrence.yearly(on: [:jan, 14], interval: 2)
    #   Recurrence.yearly(on: [:january, 14], interval: 2)
    #   Recurrence.yearly(on: [:january, 14], total: 5)
    #
    def yearly(options = {})
      branch options.merge(every: :year)
    end

    # Create a recurrence starting at given timestamp.
    #
    # @param [Time, Date] starts_at
    #
    def starting(starts_at)
      branch default_options.merge(starts: starts_at)
    end

    # Create a recurrence ending at given timestamp.
    #
    # @param [Time, Date] ends_at
    #
    def ending(ends_at)
      branch default_options.merge(until: ends_at)
    end

    def between(date_range)
      branch default_options.merge(between: date_range)
    end

    # Create a recurrence for given days of month
    #
    # @param [Fixnum] days (1, 2, -1, ...)
    #
    def day_of_month(*days)
      branch default_options.merge(mday: days)
    end

    # Create a recurrence for given days of week
    #
    # @param [Symbol] weekdays (:sunday, :monday, ...)
    #
    def day_of_week(*weekdays)
      branch default_options.merge(day: weekdays)
    end

    # Create a recurrence for given days of year
    #
    # @param [Fixnum] days (1, 10, 100, ...)
    #
    def day_of_year(*days)
      branch default_options.merge(yday: days)
    end

    # Create a recurrence for given hours of day
    #
    # @param [Fixnum, Range] days (1, 10, 100, ...)
    #
    def hour_of_day(*hours)
      branch default_options.merge(hour: hours)
    end

    # Create a recurrence for given months of year
    #
    # @param [Fixnum, Symbol] months (:january, :april, ...)
    #
    def month_of_year(*months)
      branch default_options.merge(month: months)
    end

    # Create a recurrence that ends after given number
    # of occurrences
    #
    # @param [Fixnum] total
    #
    def total(total)
      branch default_options.merge(total: total)
    end

    # Create a recurrence for given weeks of year
    #
    # @param [Fixnum] weeks (1, 20, 50)
    #
    def week_of_year(*weeks)
      branch default_options.merge(week: weeks)
    end

    # @private
    def default_options
      @default_options ||= Montrose::Options.new
    end

    # @private
    def branch(options)
      Montrose::Recurrence.new(options)
    end
  end
end
