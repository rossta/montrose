# Montrose

[![Build Status](https://travis-ci.org/rossta/montrose.svg?branch=master)](https://travis-ci.org/rossta/montrose)
[![Code Climate](https://codeclimate.com/github/rossta/montrose/badges/gpa.svg)](https://codeclimate.com/github/rossta/montrose)
[![Coverage Status](https://coveralls.io/repos/rossta/montrose/badge.svg?branch=master&service=github)](https://coveralls.io/github/rossta/montrose?branch=master)

Montrose is an easy-to-use library for defining recurring events in Ruby. It uses a simple chaining system for building recurrences, inspired heavily by the design principles of [HTTP.rb](https://github.com/httprb/http) and rule definitions available in [Recurrence](https://github.com/fnando/recurrence).

* [Introductory blog post](http://bit.ly/1PA68Zb)
* [NYC.rb
  presentation](https://speakerdeck.com/rossta/recurring-events-with-montrose)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "montrose"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install montrose

## Why

Dealing with recurring events is hard. `Montrose` provides a simple interface for specifying and enumerating recurring events as `Time` objects for Ruby applications.

More specifically, this project intends to:

* model recurring events in Ruby
* embrace Ruby idioms
* support recent Rubies
* be reasonably performant
* serialize to yaml, hash, and [ical](http://www.kanzaki.com/docs/ical/rrule.html#basic) formats
* be suitable for integration with persistence libraries

What `Montrose` doesn't do:

* support all calendaring use cases under the sun
* schedule recurring jobs for your Rails app. Use one of these instead: [cron](https://en.wikipedia.org/wiki/Cron), [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler), [sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron), [sidetiq](https://github.com/tobiassvn/sidetiq), [whenever](https://github.com/javan/whenever)

## Concepts

Montrose allows you to easily create "recurrence objects" through chaining:

```ruby
# Every Monday at 10:30am
Montrose.weekly.on(:monday).at("10:30 am")
=> #<Montrose::Recurrence...>
```

Each chained recurrence returns a **new object** so they can be composed and merged. In both examples below, recurrence `r4` represents 'every week on Tuesday and Thursday at noon for four occurrences'.

```ruby
# Example 1 - building recurrence in succession
r1 = Montrose.every(:week)
r2 = r1.on([:tuesday, :thursday])
r3 = r2.at("12 pm")
r4 = r3.total(4)

# Example 2 - merging distinct recurrences
r1 = Montrose.every(:week)
r2 = Montrose.on([:tuesday, :thursday])
r3 = Montrose.at("12 pm")
r4 = r1.merge(r2).merge(r3).total(4)
```

Most recurrence methods accept additional options if you favor the hash-syntax:

```ruby
Montrose.r(every: :week, on: :monday, at: "10:30 am")
=> #<Montrose::Recurrence...>
```

See [the docs for `Montrose::Chainable`](https://rossta.net/montrose/Montrose/Chainable.html) for more info on recurrence creation methods.

A Montrose recurrence responds to `#events`, which returns an [`Enumerator`](/blog/what-is-enumerator.html) that can generate timestamps:

```ruby
r = Montrose.hourly
=> #<Montrose::Recurrence...>

r.events
=> #<Enumerator:...>

r.events.take(10)
=> [2016-02-03 18:26:08 -0500,
2016-02-03 19:26:08 -0500,
2016-02-03 20:26:08 -0500,
2016-02-03 21:26:08 -0500,
2016-02-03 22:26:08 -0500,
2016-02-03 23:26:08 -0500,
2016-02-04 00:26:08 -0500,
2016-02-04 01:26:08 -0500,
2016-02-04 02:26:08 -0500,
2016-02-04 03:26:08 -0500]
```

Montrose recurrences are themselves enumerable:

```ruby
# Every month starting a year from now on Friday the 13th for 5 occurrences
r = Montrose.monthly.starting(1.year.from_now).on(friday: 13).repeat(5)

r.map(&:to_date)
=> [Fri, 13 Oct 2017,
Fri, 13 Apr 2018,
Fri, 13 Jul 2018,
Fri, 13 Sep 2019,
Fri, 13 Dec 2019]
```

Conceptually, recurrences can represent an infinite sequence. When we say
simply "every day", there is no implied ending. It's therefore possible to
create a recurrence that can enumerate forever, so use your `Enumerable` methods wisely.

```ruby
# Every day starting now
r = Montrose.daily

# this expression will never complete, Ctrl-c!
r.map(&:to_date)

# use `lazy` enumerator to avoid eager enumeration
r.lazy.map(&:to_date).select { |d| d.mday > 25 }.take(5).to_a
=> [Fri, 26 Feb 2016,
Sat, 27 Feb 2016,
Sun, 28 Feb 2016,
Mon, 29 Feb 2016,
Sat, 26 Mar 2016]
```

It's straightforward to convert a recurrence to a hash and back.

```ruby
opts = Montrose::Recurrence.new(every: 10.minutes).to_h
=> {:every=>:minute, :interval=>10}

Montrose::Recurrence.new(opts).take(3)
=> [2016-02-03 19:06:07 -0500,
2016-02-03 19:16:07 -0500,
2016-02-03 19:26:07 -0500]
```

A recurrence object must minimally specify a frequency, e.g. `:minute`, `:hour`, `:day`, `:week`, `:month`, or, `:year`, to be viable. Otherwise, you'll see an informative error message when attempting to enumerate the recurrence.

```ruby
r = Montrose.at("12pm")
=> #<Montrose::Recurrence...>
r.each
Montrose::ConfigurationError: Please specify the :every option
```

## Usage

```ruby
require "montrose"

# a new recurrence
Montrose.r
Montrose.recurrence
Montrose::Recurrence.new

# daily for 10 occurrences
Montrose.daily(total: 10)

# daily until December 23, 2015
starts = Date.new(2015, 1, 1)
ends = Date.new(2015, 12, 23)
Montrose.daily(starts: starts, until: ends)

# every other day forever
Montrose.daily(interval: 2)

# every 10 days 5 occurrences
Montrose.every(10.days, total: 5)

# everyday in January for 3 years
starts = Time.current.beginning_of_year
ends = Time.current.end_of_year + 2.years
Montrose.daily(month: :january, between: starts...ends)

# weekly for 10 occurrences
Montrose.weekly(total: 10)

# weekly until December 23, 2015
ends_on = Date.new(2015, 12, 23)
starts_on = ends_on - 15.weeks
Montrose.every(:week, until: ends_on, starts: starts_on)

# every other week forever
Montrose.every(2.weeks)

# weekly on Tuesday and Thursday for five weeks
# from September 1, 2015 until October 5, 2015
Montrose.weekly(on: [:tuesday, :thursday],
  between: Date.new(2015, 9, 1)..Date.new(2015, 10, 5))

# every other week on Monday, Wednesday and Friday until December 23 2015,
# but starting on Tuesday, September 1, 2015
Montrose.every(2.weeks,
  on: [:monday, :wednesday, :friday],
  starts: Date.new(2015, 9, 1))

# every other week on Tuesday and Thursday, for 8 occurrences
Montrose.weekly(on: [:tuesday, :thursday], total: 8, interval: 2)

# monthly on the first Friday for ten occurrences
Montrose.monthly(day: { friday: [1] }, total: 10)

# monthly on the first Friday until December 23, 2015
Montrose.every(:month, day: { friday: [1] }, until: Date.new(2016, 12, 23))

# every other month on the first and last Sunday of the month for 10 occurrences
Montrose.every(:month, day: { sunday: [1, -1] }, interval: 2, total: 10)

# monthly on the second-to-last Monday of the month for 6 months
Montrose.every(:month, day: { monday: [-2] }, total: 6)

# monthly on the third-to-the-last day of the month, forever
Montrose.every(:month, mday: [-3])

# monthly on the 2nd and 15th of the month for 10 occurrences
Montrose.every(:month, mday: [2, 15], total: 10)

# monthly on the first and last day of the month for 10 occurrences
Montrose.monthly(mday: [1, -1], total: 10)

# every 18 months on the 10th thru 15th of the month for 10 occurrences
Montrose.every(18.months, total: 10, mday: 10..15)

# every Tuesday, every other month
Montrose.every(2.months, on: :tuesday)

# yearly in June and July for 10 occurrences
Montrose.yearly(month: [:june, :july], total: 10)

# every other year on January, February, and March for 10 occurrences
Montrose.every(2.years, month: [:january, :february, :march], total: 10)

# every third year on the 1st, 100th and 200th day for 10 occurrences
Montrose.yearly(yday: [1, 100, 200], total: 10)

# every 20th Monday of the year, forever
Montrose.yearly(day: { monday: [20] })

# Monday of week number 20 forever
Montrose.yearly(week: [20], on: :monday)

# every Thursday in March, forever
Montrose.monthly(month: :march, on: :thursday, at: "12 pm")

# every Thursday, but only during June, July, and August, forever" do
Montrose.monthly(month: 6..8, on: :thursday)

# every Friday 13th, forever
Montrose.monthly(on: { friday: 13 })

# first Saturday that follows the first Sunday of the month, forever
Montrose.monthly(on: { saturday: 7..13 })

# every four years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)
Montrose.every(4.years, month: :november, on: { tuesday: 2..8 })

# every 3 hours from 9:00 AM to 5:00 PM on a specific day
date = Date.new(2016, 9, 1)
Montrose.hourly(between: date..(date+1), hour: 9..17, interval: 3)

# every 15 minutes for 6 occurrences
Montrose.every(90.minutes, total: 6)

# every hour and a half for four occurrences
Montrose.every(90.minutes, total: 4)

# every 20 minutes from 9:00 AM to 4:40 PM every day
Montrose.every(20.minutes, hour: 9..16)

# Minutely
Montrose.minutely
Montrose.r(every: :minute)

Montrose.every(10.minutes)
Montrose.r(every: 10.minutes)
Montrose.r(every: :minute, interval: 10) # every 10 minutes

Montrose.minutely(until: "9:00 PM")
Montrose.r(every: :minute, until: "9:00 PM")

# Daily
Montrose.daily
Montrose.every(:day)
Montrose.r(every: :day)

Montrose.every(9.days)
Montrose.r(every: 9.days)
Montrose.r(every: :day, interval: 9)

Montrose.daily(at: "9:00 AM")
Montrose.every(:day, at: "9:00 AM")
Montrose.r(every: :day, at: "9:00 AM")

Montrose.daily(total: 7)
Montrose.every(:day, total: 7)
Montrose.r(every: :day, total: 7)

# Weekly
Montrose.weekly
Montrose.every(:week)
Montrose.r(every: :week)

Montrose.every(:week, on: :monday)
Montrose.every(:week, on: [:monday, :wednesday, :friday])
Montrose.every(2.weeks, on: :friday)
Montrose.every(:week, on: :friday, at: "3:41 PM")
Montrose.weekly(on: :thursday)

# Monthly by month day
Montrose.monthly(mday: 1) # first of the month
Montrose.every(:month, mday: 1)
Montrose.r(every: :month, mday: 1)

Montrose.monthly(mday: [2, 15]) # 2nd and 15th of the month
Montrose.monthly(mday: -3) # third-to-last day of the month
Montrose.monthly(mday: 10..15) # 10th through the 15th day of the month

# Monthly by week day
Montrose.monthly(day: :friday, interval: 2) # every Friday every other month
Montrose.every(:month, day: :friday, interval: 2)
Montrose.r(every: :month, day: :friday, interval: 2)

Montrose.monthly(day: { friday: [1] }) # 1st Friday of the month
Montrose.monthly(day: { sunday: [1, -1] }) # first and last Sunday of the month

Montrose.monthly(mday: 7..13, day: :saturday) # first Saturday that follow the first Sunday of the month

# Yearly
Montrose.yearly
Montrose.every(:year)
Montrose.r(every: :year)

Montrose.yearly(month: [:june, :july]) # yearly in June and July
Montrose.yearly(month: 6..8, day: :thursday) # yearly in June, July, August on Thursday
Montrose.yearly(yday: [1, 100]) # yearly on the 1st and 100th day of year

Montrose.yearly(on: { january: 31 })
Montrose.r(every: :year, on: { 10 => 31 }, interval: 3)

# Chaining
Montrose.weekly.starting(3.weeks.from_now).on(:friday)
Montrose.every(:day).at("4:05pm")
Montrose.yearly.between(Time.current..10.years.from_now)

# Enumerating events
r = Montrose.every(:month, mday: 31, until: "January 1, 2017")
r.each { |time| puts time.to_s }
r.take(10).to_a

# Merging rules
r.merge(starts: "2017-01-01").each { |time| puts time.to_s }

# Using #events Enumerator
r.events # => #<Enumerator: ...>
r.events.take(10).each { |date| puts date.to_s }
r.events.lazy.select { |time| time > 1.month.from_now }.take(3).each { |date| puts date.to_s }
```

### Ruby on Rails

Instances of `Montrose::Recurrence` support the ActiveRecord serialization API so recurrence objects can be marshalled to and from a single database column:

```ruby
class RecurringEvent < ApplicationRecord
  serialize :recurrence, Montrose::Recurrence

end
```

## Inspiration

Montrose is named after the beautifully diverse and artistic [neighborhood in Houston, Texas](https://en.wikipedia.org/wiki/Montrose,_Houston).

### Related Projects

Check out following related projects, all of which have provided inspiration for `Montrose`.

* [ice_cube](https://github.com/seejohnrun/ice_cube)
* [recurrence](https://github.com/fnando/recurrence)
* [runt](https://github.com/mlipper/runt)
* [http.rb](https://github.com/httprb/http) - not a recurrence project, but inspirational to design, implementation, and interface of `Montrose`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rossta/montrose. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
