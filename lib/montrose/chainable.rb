# frozen_string_literal: true

require "montrose/refinements/array_concat"

module Montrose
  module Chainable
    using Montrose::Refinements::ArrayConcat

    # Create a recurrence from the given frequency
    #
    # @param frequency [Symbol,String,Numeric] the recurrence frequency
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.every(:hour)
    #   Montrose.every(:hour, interval: 2)
    #   Montrose.every(3.days, starts: 2.days.from_now)
    #   Montrose.every(1.year, until: 10.days.from_now)
    #
    # @return [Montrose::Recurrence]
    #
    def every(frequency, options = {})
      branch options.merge(every: frequency)
    end

    # Create a minutely recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.minutely
    #   Montrose.minutely(interval: 2) #=> every 2 minutes
    #   Montrose.minutely(starts: 3.days.from_now)
    #   Montrose.minutely(until: 10.days.from_now)
    #   Montrose.minutely(total: 5)
    #   Montrose.minutely(except: Date.tomorrow)
    #
    # @return [Montrose::Recurrence]
    #
    def minutely(options = {})
      branch options.merge(every: :minute)
    end

    # Create a hourly recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.hourly
    #   Montrose.hourly(interval: 2) #=> every 2 hours
    #   Montrose.hourly(starts: 3.days.from_now)
    #   Montrose.hourly(until: 10.days.from_now)
    #   Montrose.hourly(total: 5)
    #   Montrose.hourly(except: Date.tomorrow)
    #
    # @return [Montrose::Recurrence]
    #
    def hourly(options = {})
      branch options.merge(every: :hour)
    end

    # Create a daily recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.daily
    #   Montrose.daily(interval: 2) #=> every 2 days
    #   Montrose.daily(starts: 3.days.from_now)
    #   Montrose.daily(until: 10.days.from_now)
    #   Montrose.daily(total: 5)
    #   Montrose.daily(except: Date.tomorrow)
    #
    # @return [Montrose::Recurrence]
    #
    def daily(options = {})
      branch options.merge(every: :day)
    end

    # Create a weekly recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.weekly(on: 5) #=> 0 = sunday, 1 = monday, ...
    #   Montrose.weekly(on: :saturday)
    #   Montrose.weekly(on: [sunday, :saturday])
    #   Montrose.weekly(on: :saturday, interval: 2)
    #   Montrose.weekly(on: :saturday, total: 5)
    #
    # @return [Montrose::Recurrence]
    #
    def weekly(options = {})
      branch options.merge(every: :week)
    end

    # Create a monthly recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.monthly(mday: [2, 15]) # 2nd and 15th of the month
    #   Montrose.monthly(mday: -3) # third-to-last day of the month
    #   Montrose.monthly(mday: 10..15) # 10th through the 15th day of the month
    #
    # @return [Montrose::Recurrence]
    #
    def monthly(options = {})
      branch options.merge(every: :month)
    end

    # Create a yearly recurrence.
    #
    # @param options [Hash] additional recurrence options
    #
    # @example
    #   Montrose.yearly(on: [7, 14]) #=> every Jul 14
    #   Montrose.yearly(on: [7, 14], interval: 2) #=> every 2 years on Jul 14
    #   Montrose.yearly(on: [:jan, 14], interval: 2)
    #   Montrose.yearly(on: [:january, 14], interval: 2)
    #   Montrose.yearly(on: [:january, 14], total: 5)
    #
    # @return [Montrose::Recurrence]
    #
    def yearly(options = {})
      branch options.merge(every: :year)
    end

    # Create a recurrence starting at given timestamp.
    #
    # @param starts_at [Time, Date] start time of recurrence
    #
    # @example
    #   Montrose.daily.starting(Date.tomorrow)
    #
    # @return [Montrose::Recurrence]
    #
    def starts(starts_at)
      merge(starts: starts_at)
    end
    alias_method :starting, :starts

    # Create a recurrence ending at given timestamp.
    #
    # @param ends_at [Time, Date] end time of recurrence
    #
    # @example
    #   Montrose.daily.ending(1.year.from_now)
    #
    # @return [Montrose::Recurrence]
    #
    def until(ends_at)
      merge(until: ends_at)
    end
    alias_method :ending, :until

    # Create a recurrence occurring between the start and end
    # of a given date range; :between is shorthand for separate
    # :starts and :until options. When used with explicit :start
    # and/or :until options, those will take precedence.
    #
    # @param [Range<Date>] date_range
    #
    # @example
    #   Montrose.weekly.between(Date.today..Date.new(2016, 3, 15))
    #
    # @return [Montrose::Recurrence]
    #
    def between(date_range)
      merge(between: date_range)
    end

    # Create a recurrence which will only emit values within the
    # date range, also called "masking."
    #
    # @param [Range<Date>] date_range
    #
    # @example
    #   Montrose.weekly.covering(Date.tomorrow..Date.new(2016, 3, 15))
    #
    # @return [Montrose::Recurrence]
    #
    def covering(date_range)
      merge(covering: date_range)
    end

    # Create a recurrence occurring within a time-of-day range or ranges.
    # Given time ranges will parse as times-of-day and ignore given dates.
    #
    # @param [Range<Time>,String,Array<Array>] time-of-day range(s)
    #
    # @example
    #   Montrose.every(20.minutes).during("9am-5pm")
    #   Montrose.every(20.minutes).during(time.change(hour: 9)..time.change(hour: 5))
    #   Montrose.every(20.minutes).during([9, 0, 0], [17, 0, 0])
    #   Montrose.every(20.minutes).during("9am-12pm", "1pm-5pm")
    #
    # @return [Montrose::Recurrence]
    #
    def during(time_of_day, *extras)
      merge(during: time_of_day.array_concat(extras))
    end

    # Create a recurrence through :on option
    #
    # @param day [Hash,Symbol] weekday or day of month as hash, e.g. { friday: 13 }
    #
    # @example
    #   Montrose.weekly.on(:friday)
    #   Montrose.monthly.on(friday: 13)
    #
    # @return [Montrose::Recurrence]
    #
    def on(day)
      merge(on: day)
    end

    # Create a recurrence at given time
    #
    # @param time [String,Time] represents time of day
    #
    # @example
    #   Montrose.daily.at("12pm")
    #   Montrose.daily.at("9:37am")
    #
    # @return [Montrose::Recurrence]
    #
    def at(time)
      merge(at: time)
    end

    # Create a recurrence with dates except dates given
    #
    # @param date [String, Date] represents date
    #
    # @example
    #   Montrose.daily.except("2016-03-01")
    #   Montrose.daily.except(Date.today)
    #
    # @return [Montrose::Recurrence]
    #
    def except(date)
      merge(except: date)
    end

    # Create a recurrence for given days of month
    #
    # @param days [Fixnum] days of month, e.g. 1, 2, -1, ...
    #
    # @example
    #   Montrose.daily.day_of_month(1, -1)
    #   Montrose.daily.day_of_month([1, -1])
    #   Montrose.daily.day_of_month(2..8)
    #
    # @return [Montrose::Recurrence]
    #
    def day_of_month(days, *extras)
      merge(mday: days.array_concat(extras))
    end
    alias_method :mday, :day_of_month

    # Create a recurrence for given days of week
    #
    # @param weekdays [Symbol] days of week, e.g. :sunday, :monday, ...
    #
    # @example
    #   Montrose.daily.day_of_week(:saturday)
    #   Montrose.daily.day_of_week(:monday, :tuesday)
    #   Montrose.daily.day_of_week(2..5)
    #
    # @return [Montrose::Recurrence]
    #
    def day_of_week(weekdays, *extras)
      merge(day: weekdays.array_concat(extras))
    end
    alias_method :day, :day_of_week

    # Create a recurrence for given days of year
    #
    # @param days [Fixnum, Range, Array<Integer>] days of year, e.g., 1, 10, 100, ...
    #
    # @example
    #   Montrose.daily.day_of_year(1, 10, 100)
    #   Montrose.daily.day_of_year([1, 10, 100])
    #   Montrose.daily.day_of_year(20..50)
    #
    # @return [Montrose::Recurrence]
    #
    def day_of_year(days, *extras)
      merge(yday: days.array_concat(extras))
    end
    alias_method :yday, :day_of_year

    # Create a recurrence for given hours of day
    #
    # @param hours [Fixnum, Range, Array<Integer>] hours of day, e.g. 1, 10, 100, ...
    #
    # @example
    #   Montrose.hourly.hour_of_day(9)
    #   Montrose.hourly.hour_of_day(15)
    #   Montrose.hourly.hour_of_day(6..10)
    #
    # @return [Montrose::Recurrence]
    #
    def hour_of_day(hours, *extras)
      merge(hour: hours.array_concat(extras))
    end
    alias_method :hour, :hour_of_day

    # Create a recurrence for given months of year
    #
    # @param months [Fixnum, Symbol] months of year, e.g., :january, :april, ...
    #
    # @example
    #   Montrose.monthly.month_of_year(9)
    #   Montrose.monthly.month_of_year([2, 5])
    #   Montrose.monthly.month_of_year(2..5)
    #
    # @return [Montrose::Recurrence]
    #
    def month_of_year(months, *extras)
      merge(month: months.array_concat(extras))
    end
    alias_method :month, :month_of_year

    # Create a recurrence for given weeks of year
    #
    # @param weeks [Fixnum] weeks of year, e.g., 1, 20, 50
    #
    # @example
    #   Montrose.weekly.week_of_year(9)
    #   Montrose.weekly.week_of_year([2, 5])
    #   Montrose.weekly.week_of_year(2..5)
    #
    # @return [Montrose::Recurrence]
    #
    def week_of_year(weeks, *extras)
      merge(week: weeks.array_concat(extras))
    end

    # Create a recurrence that ends after given number
    # of occurrences
    #
    # @param total [Fixnum] repeat count
    #
    # @example
    #   Montrose.daily.total(10)
    #
    # @return [Montrose::Recurrence]
    #
    def total(total)
      merge(total: total)
    end
    alias_method :repeat, :total

    # Create a new recurrence combining options of self
    # and other. The value of entries with duplicate
    # keys will be those of other
    #
    # @param other [Hash,Montrose::Recurrence] other options or recurrence
    #
    # @example
    #   Montrose.daily.total(10)
    #
    # @return [Montrose::Recurrence]
    #
    def merge(other = {})
      branch default_options.merge(other)
    end

    # @private
    def branch(options)
      Montrose::Recurrence.new(options)
    end

    # @private
    def default_options
      @default_options ||= Montrose::Options.new
    end
  end
end
