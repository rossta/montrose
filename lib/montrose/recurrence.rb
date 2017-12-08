# frozen_string_literal: true

require "json"
require "yaml"
require "montrose/chainable"
require "montrose/errors"
require "montrose/stack"
require "montrose/clock"

module Montrose
  # Represents the rules for a set of recurring events. Can be instantiated
  # and extended in a variety of ways as show in the examples below.
  #
  # @author Ross Kaffenberger
  # @since 0.0.1
  # @attr_reader [Montrose::Options] default_options contains the recurrence rules in hash-like format
  #
  # @example a new recurrence
  #   Montrose.r
  #   Montrose.recurrence
  #   Montrose::Recurrence.new
  #
  # @example daily for 10 occurrences
  #   Montrose.daily(total: 10)
  #
  # @example daily until December 23, 2015
  #   starts = Date.new(2015, 1, 1)
  #   ends = Date.new(2015, 12, 23)
  #   Montrose.daily(starts: starts, until: ends)
  #
  # @example every other day forever
  #   Montrose.daily(interval: 2)
  #
  # @example every 10 days 5 occurrences
  #   Montrose.every(10.days, total: 5)
  #
  # @example everyday in January for 3 years
  #   starts = Time.current.beginning_of_year
  #   ends = Time.current.end_of_year + 2.years
  #   Montrose.daily(month: :january, between: starts...ends)
  #
  # @example weekly for 10 occurrences
  #   Montrose.weekly(total: 10)
  #
  # @example weekly until December 23, 2015
  #   ends_on = Date.new(2015, 12, 23)
  #   starts_on = ends_on - 15.weeks
  #   Montrose.every(:week, until: ends_on, starts: starts_on)
  #
  # @example every other week forever
  #   Montrose.every(2.weeks)
  #
  # @example weekly on Tuesday and Thursday for five weeks from September 1, 2015 until October 5, 2015
  #   Montrose.weekly(on: [:tuesday, :thursday],
  #     between: Date.new(2015, 9, 1)..Date.new(2015, 10, 5))
  #
  # @example every other week on Mon, Wed and Fri until December 23 2015, but starting on Tuesday, September 1, 2015
  #   Montrose.every(2.weeks,
  #     on: [:monday, :wednesday, :friday],
  #     starts: Date.new(2015, 9, 1))
  #
  # @example every other week on Tuesday and Thursday, for 8 occurrences
  #   Montrose.weekly(on: [:tuesday, :thursday], total: 8, interval: 2)
  #
  # @example monthly on the first Friday for ten occurrences
  #   Montrose.monthly(day: { friday: [1] }, total: 10)
  #
  # @example monthly on the first Friday until December 23, 2015
  #   Montrose.every(:month, day: { friday: [1] }, until: Date.new(2016, 12, 23))
  #
  # @example every other month on the first and last Sunday of the month for 10 occurrences
  #   Montrose.every(:month, day: { sunday: [1, -1] }, interval: 2, total: 10)
  #
  # @example monthly on the second-to-last Monday of the month for 6 months
  #   Montrose.every(:month, day: { monday: [-2] }, total: 6)
  #
  # @example monthly on the third-to-the-last day of the month, forever
  #   Montrose.every(:month, mday: [-3])
  #
  # @example monthly on the 2nd and 15th of the month for 10 occurrences
  #   Montrose.every(:month, mday: [2, 15], total: 10)
  #
  # @example monthly on the first and last day of the month for 10 occurrences
  #   Montrose.monthly(mday: [1, -1], total: 10)
  #
  # @example every 18 months on the 10th thru 15th of the month for 10 occurrences
  #   Montrose.every(18.months, total: 10, mday: 10..15)
  #
  # @example every Tuesday, every other month
  #   Montrose.every(2.months, on: :tuesday)
  #
  # @example yearly in June and July for 10 occurrences
  #   Montrose.yearly(month: [:june, :july], total: 10)
  #
  # @example every other year on January, February, and March for 10 occurrences
  #   Montrose.every(2.years, month: [:january, :february, :march], total: 10)
  #
  # @example every third year on the 1st, 100th and 200th day for 10 occurrences
  #   Montrose.yearly(yday: [1, 100, 200], total: 10)
  #
  # @example every 20th Monday of the year, forever
  #   Montrose.yearly(day: { monday: [20] })
  #
  # @example Monday of week number 20 forever
  #   Montrose.yearly(week: [20], on: :monday)
  #
  # @example every Thursday in March, forever
  #   Montrose.monthly(month: :march, on: :thursday, at: "12 pm")
  #
  # @example every Thursday, but only during June, July, and August, forever" do
  #   Montrose.monthly(month: 6..8, on: :thursday)
  #
  # @example every Friday 13th, forever
  #   Montrose.monthly(on: { friday: 13 })
  #
  # @example first Saturday that follows the first Sunday of the month, forever
  #   Montrose.monthly(on: { saturday: 7..13 })
  #
  # @example every four years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)
  #   Montrose.every(4.years, month: :november, on: { tuesday: 2..8 })
  #
  # @example every 3 hours from 9:00 AM to 5:00 PM on a specific day
  #   date = Date.new(2016, 9, 1)
  #   Montrose.hourly(between: date..(date+1), hour: 9..17, interval: 3)
  #
  # @example every 15 minutes for 6 occurrences
  #   Montrose.every(90.minutes, total: 6)
  #
  # @example every hour and a half for four occurrences
  #   Montrose.every(90.minutes, total: 4)
  #
  # @example every 20 minutes from 9:00 AM to 4:40 PM every day
  #   Montrose.every(20.minutes, hour: 9..16)
  #
  # @example Minutely
  #   Montrose.minutely
  #   Montrose.r(every: :minute)
  #   Montrose.every(10.minutes)
  #   Montrose.r(every: 10.minutes)
  #   Montrose.r(every: :minute, interval: 10) # every 10 minutes
  #   Montrose.minutely(until: "9:00 PM")
  #   Montrose.r(every: :minute, until: "9:00 PM")
  #
  # @example Daily
  #   Montrose.daily
  #   Montrose.every(:day)
  #   Montrose.r(every: :day)
  #   Montrose.every(9.days)
  #   Montrose.r(every: 9.days)
  #   Montrose.r(every: :day, interval: 9)
  #   Montrose.daily(at: "9:00 AM")
  #   Montrose.every(:day, at: "9:00 AM")
  #   Montrose.r(every: :day, at: "9:00 AM")
  #   Montrose.daily(total: 7)
  #   Montrose.every(:day, total: 7)
  #   Montrose.r(every: :day, total: 7)
  #
  # @example Weekly
  #   Montrose.weekly
  #   Montrose.every(:week)
  #   Montrose.r(every: :week)
  #   Montrose.every(:week, on: :monday)
  #   Montrose.every(:week, on: [:monday, :wednesday, :friday])
  #   Montrose.every(2.weeks, on: :friday)
  #   Montrose.every(:week, on: :friday, at: "3:41 PM")
  #   Montrose.weekly(on: :thursday)
  #
  # @example Monthly by month day
  #   Montrose.monthly(mday: 1) # first of the month
  #   Montrose.every(:month, mday: 1)
  #   Montrose.r(every: :month, mday: 1)
  #   Montrose.monthly(mday: [2, 15]) # 2nd and 15th of the month
  #   Montrose.monthly(mday: -3) # third-to-last day of the month
  #   Montrose.monthly(mday: 10..15) # 10th through the 15th day of the month
  #
  # @example Monthly by week day
  #   Montrose.monthly(day: :friday, interval: 2) # every Friday every other month
  #   Montrose.every(:month, day: :friday, interval: 2)
  #   Montrose.r(every: :month, day: :friday, interval: 2)
  #   Montrose.monthly(day: { friday: [1] }) # 1st Friday of the month
  #   Montrose.monthly(day: { Sunday: [1, -1] }) # first and last Sunday of the month
  #   Montrose.monthly(mday: 7..13, day: :saturday) # first Saturday that follow the first Sunday of the month
  #
  # @example Yearly
  #   Montrose.yearly
  #   Montrose.every(:year)
  #   Montrose.r(every: :year)
  #   Montrose.yearly(month: [:june, :july]) # yearly in June and July
  #   Montrose.yearly(month: 6..8, day: :thursday) # yearly in June, July, August on Thursday
  #   Montrose.yearly(yday: [1, 100]) # yearly on the 1st and 100th day of year
  #   Montrose.yearly(on: { january: 31 })
  #   Montrose.r(every: :year, on: { 10 => 31 }, interval: 3)
  #
  # @example Chaining
  #   Montrose.weekly.starting(3.weeks.from_now).on(:friday)
  #   Montrose.every(:day).at("4:05pm")
  #   Montrose.yearly.between(Time.current..10.years.from_now)
  #
  # @example Enumerating events
  #   r = Montrose.every(:month, mday: 31, until: "January 1, 2017")
  #   r.each { |time| puts time.to_s }
  #   r.take(10).to_a
  #
  # @example Merging rules
  #   r.merge(starts: "2017-01-01").each { |time| puts time.to_s }
  #
  # @example Using #events Enumerator
  #   r.events # => #<Enumerator: ...>
  #   r.events.take(10).each { |date| puts date.to_s }
  #   r.events.lazy.select { |time| time > 1.month.from_now }.take(3).each { |date| puts date.to_s }
  #
  class Recurrence
    extend Forwardable
    include Chainable
    include Enumerable

    attr_reader :default_options
    def_delegator :@default_options, :total, :length
    def_delegator :@default_options, :starts, :starts_at
    def_delegator :@default_options, :until, :ends_at

    class << self
      def new(options = {})
        return options if options.is_a?(self)
        super
      end

      def dump(obj)
        return nil if obj.nil?
        return dump(load(obj)) if obj.is_a?(String)

        hash = case obj
               when Hash
                 obj
               when self
                 obj.to_hash
               else
                 fail SerializationError,
                   "Object was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
               end

        JSON.dump(hash)
      end

      def load(json)
        return nil if json.blank?

        new JSON.parse(json)
      rescue JSON::ParserError => e
        fail SerializationError, "Could not parse JSON: #{e}"
      end
    end

    def initialize(opts = {})
      @default_options = Montrose::Options.new(opts)
    end

    # Returns an enumerator for iterating over timestamps in the recurrence
    #
    # @example Return the events
    #   recurrence = Montrose.recurrence(every: :day)
    #   recurrence.events
    #
    # @example Iterate over a finite recurrence
    #   recurrence = Montrose.recurrence(every: :day, until: 1.year.from_now)
    #   recurrence.events.each do |event|
    #     puts event
    #   end
    #
    # @example Iterate over an infinite recurrence
    #   recurrence = Montrose.recurrence(every: :day)
    #   recurrence.events.lazy.each do |event|
    #     puts event
    #   end
    #
    # @return [Enumerator] an enumerator of recurrence timestamps
    #
    def events
      event_enum
    end

    # Iterate over the events of a recurrence. Along with the Enumerable
    # module, this makes Montrose occurrences enumerable like other Ruby
    # collections
    #
    # @example Iterate over a finite recurrence
    #   recurrence = Montrose.recurrence(every: :day, until: 1.year.from_now)
    #   recurrence.each do |event|
    #     puts event
    #   end
    #
    # @example Iterate over an infinite recurrence
    #   recurrence = Montrose.recurrence(every: :day)
    #   recurrence.lazy.each do |event|
    #     puts event
    #   end
    #
    # @return [Enumerator] an enumerator of recurrence timestamps
    def each(&block)
      events.each(&block)
    end

    # Returns a hash of the options used to create the recurrence
    #
    # @return [Hash] hash of recurrence options
    #
    def to_hash
      default_options.to_hash
    end
    alias to_h to_hash

    # Returns json string of options used to create the recurrence
    #
    # @return [String] json of recurrence options
    #
    def to_json(*args)
      JSON.dump(to_hash, *args)
    end

    # Returns options used to create the recurrence in YAML format
    #
    # @return [String] YAML-formatted recurrence options
    #
    def to_yaml(*args)
      YAML.dump(to_hash, *args)
    end

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{to_h.inspect}>"
    end

    # Return true/false if given timestamp equals a timestamp given
    # by the recurrence
    #
    # @return [Boolean] whether or not timestamp is included in recurrence
    #
    def include?(timestamp)
      return false if earlier?(timestamp) || later?(timestamp)

      recurrence = finite? ? self : starts(timestamp)

      recurrence.events.lazy.each do |event|
        return true if event == timestamp
        return false if event > timestamp
      end or false
    end

    # Return true/false if recurrence will iterate infinitely
    #
    # @return [Boolean] whether or not recurrence is infinite
    #
    def finite?
      ends_at || length
    end

    # Return true/false if given timestamp occurs before
    # the recurrence
    #
    # @return [Boolean] whether or not timestamp is earlier
    #
    def earlier?(timestamp)
      starts_at && timestamp < starts_at
    end

    # Return true/false if given timestamp occurs after
    # the recurrence
    #
    # @return [Boolean] whether or not timestamp is later
    #
    def later?(timestamp)
      ends_at && timestamp > ends_at
    end

    private

    def event_enum
      opts = Options.merge(@default_options)
      stack = Stack.new(opts)
      clock = Clock.new(opts)

      Enumerator.new do |yielder|
        loop do
          stack.advance(clock.tick) do |time|
            yielder << time
          end or break
        end
      end
    end
  end
end
