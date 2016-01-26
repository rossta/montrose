require "montrose/options"
require "montrose/refinements/array_concat"

module Montrose
  module Chainable
    using Montrose::Refinements::ArrayConcat

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
    #   Montrose.daily
    #   Montrose.daily(interval: 2) #=> every 2 days
    #   Montrose.daily(starts: 3.days.from_now)
    #   Montrose.daily(until: 10.days.from_now)
    #   Montrose.daily(total: 5)
    #   Montrose.daily(except: Date.tomorrow)
    #
    def daily(options = {})
      branch options.merge(every: :day)
    end

    # Create a weekly recurrence.
    #
    # @example
    #   Montrose.weekly(on: 5) #=> 0 = sunday, 1 = monday, ...
    #   Montrose.weekly(on: :saturday)
    #   Montrose.weekly(on: [sunday, :saturday])
    #   Montrose.weekly(on: :saturday, interval: 2)
    #   Montrose.weekly(on: :saturday, total: 5)
    #
    def weekly(options = {})
      branch options.merge(every: :week)
    end

    # Create a monthly recurrence.
    #
    # @example
    # Montrose.monthly(mday: [2, 15]) # 2nd and 15th of the month
    # Montrose.monthly(mday: -3) # third-to-last day of the month
    # Montrose.monthly(mday: 10..15) # 10th through the 15th day of the month
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
    #   Montrose.yearly(on: [7, 14]) #=> every Jul 14
    #   Montrose.yearly(on: [7, 14], interval: 2) #=> every 2 years on Jul 14
    #   Montrose.yearly(on: [:jan, 14], interval: 2)
    #   Montrose.yearly(on: [:january, 14], interval: 2)
    #   Montrose.yearly(on: [:january, 14], total: 5)
    #
    def yearly(options = {})
      branch options.merge(every: :year)
    end

    # Create a recurrence starting at given timestamp.
    #
    # @param [Time, Date] starts_at
    #
    def starting(starts_at)
      merge(starts: starts_at)
    end

    # Create a recurrence ending at given timestamp.
    #
    # @param [Time, Date] ends_at
    #
    def ending(ends_at)
      merge(until: ends_at)
    end

    # Create a recurrence occurring during date range.
    #
    # @param [Range<Date>] date_range
    #
    def between(date_range)
      merge(between: date_range)
    end

    # Create a recurrence through :on option
    #
    # @param [Hash,Symbol] on { friday: 13 }
    #
    def on(day)
      merge(on: day)
    end

    # Create a recurrence at given time
    #
    # @param [String,Time] at
    #
    def at(time)
      merge(at: time)
    end

    # Create a recurrence for given days of month
    #
    # @param [Fixnum] days (1, 2, -1, ...)
    #
    def day_of_month(days, *extras)
      merge(mday: days.array_concat(extras))
    end
    alias mday day_of_month

    # Create a recurrence for given days of week
    #
    # @param [Symbol] weekdays (:sunday, :monday, ...)
    #
    def day_of_week(weekdays, *extras)
      merge(day: weekdays.array_concat(extras))
    end
    alias day day_of_week

    # Create a recurrence for given days of year
    #
    # @param [Fixnum] days (1, 10, 100, ...)
    #
    def day_of_year(days, *extras)
      merge(yday: days.array_concat(extras))
    end
    alias yday day_of_year

    # Create a recurrence for given hours of day
    #
    # @param [Fixnum, Range] days (1, 10, 100, ...)
    #
    def hour_of_day(hours, *extras)
      merge(hour: hours.array_concat(extras))
    end
    alias hour hour_of_day

    # Create a recurrence for given months of year
    #
    # @param [Fixnum, Symbol] months (:january, :april, ...)
    #
    def month_of_year(months, *extras)
      merge(month: months.array_concat(extras))
    end
    alias month month_of_year

    # Create a recurrence that ends after given number
    # of occurrences
    #
    # @param [Fixnum] total
    #
    def total(total)
      merge(total: total)
    end

    # Create a recurrence for given weeks of year
    #
    # @param [Fixnum] weeks (1, 20, 50)
    #
    def week_of_year(weeks, *extras)
      merge(week: weeks.array_concat(extras))
    end

    # @private
    def merge(opts = {})
      branch default_options.merge(opts)
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
