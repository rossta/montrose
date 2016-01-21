# Montrose

[![Build Status](https://travis-ci.org/rossta/montrose.svg?branch=master)](https://travis-ci.org/rossta/montrose)
[![Coverage Status](https://coveralls.io/repos/rossta/montrose/badge.svg?branch=master&service=github)](https://coveralls.io/github/rossta/montrose?branch=master)
[![Code Climate](https://codeclimate.com/github/rossta/montrose/badges/gpa.svg)](https://codeclimate.com/github/rossta/montrose)
[![Dependency Status](https://gemnasium.com/rossta/montrose.svg)](https://gemnasium.com/rossta/montrose)

Recurring events in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "montrose"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install montrose

## Usage

```ruby
require "montrose"

# Minutely
Montrose.minutely
Montrose::Recurrence.new(every: :minute)

Montrose.every(10.minutes)
Montrose::Recurrence.new(every: 10.minutes)
Montrose::Recurrence.new(every: :minute, interval: 10) # every 10 minutes

Montrose.minutely(until: "9:00 PM")
Montrose::Recurrence.new(every: :minute, until: "9:00 PM")

# Daily
Montrose.daily
Montrose::Recurrence.new(every: :day)

Montrose.every(9.days)
Montrose::Recurrence.new(every: 9.days)
Montrose::Recurrence.new(every: :day, interval: 9)

Montrose.daily(at: "9:00 AM")
Montrose.every(:day, at: "9:00 AM")
Montrose::Recurrence.new(every: :day, at: "9:00 AM")

Montrose.daily(total: 7)
Montrose.every(:day, total: 7)
Montrose::Recurrence.new(every: :day, total: 7)

# Weekly
Montrose.weekly
Montrose.every(:week)
Montrose::Recurrence.new(every: :week)

Montrose.every(:week, on: :monday)
Montrose.every(:week, on: [:monday, :wednesday, :friday])
Montrose.every(2.weeks, on: :friday)
Montrose.every(:week, on: :friday, at: "3:41 PM")
Montrose.weekly(on: :thursday)

# Monthly by month day
Montrose.monthly(mday: 1) # first of the month
Montrose.every(:month, mday: 1)
Montrose::Recurrence.new(every: :month, mday: 1)

Montrose.monthly(mday: [2, 15]) # 2nd and 15th of the month
Montrose.monthly(mday: -3) # third-to-last day of the month
Montrose.monthly(mday: 10..15) # 10th through the 15th day of the month

# Monthly by week day
Montrose.monthly(day: :friday, interval: 2) # every Friday every other month
Montrose.every(:month, day: :friday, interval: 2)
Montrose::Recurrence.new(every: :month, day: :friday, interval: 2)

Montrose.monthly(day: { friday: [1] }) # 1st Friday of the month
Montrose.monthly(day: { Sunday: [1, -1] }) # first and last Sunday of the month

Montrose.monthly(mday: 7..13, day: :saturday) # first Saturday that follow the
first Sunday of the month

# Yearly
Montrose.yearly
Montrose.every(:year)
Montrose::Recurrence.new(every: :year)

Montrose.yearly(month: [:june, :july]) # yearly in June and July
Montrose.yearly(month: 6..8, day: :thursday) # yearly in June, July, August on
Thursday
Montrose.yearly(yday: [1, 100]) # yearly on the 1st and 100th day of year
Montrose.every(4.years, month: :november, on: { tuesday: 2..8 }) # every four years, the first Tuesday after a Monday in November, i.e., Election Day

Montrose::Recurrence.yearly(on: { january: 31 })
Montrose::Recurrence.new(every: :year, on: { 10 => 31 }, interval: 3)

# TODO: Remove a date in the series on the given except date(s)
# :except defaults to being unset
Montrose::Recurrence.new(every: :day, except: "2017-01-31")
Montrose::Recurrence.new(every: :day, except: [Date.today, "2017-01-31"])

# Enumerating events
r = Montrose::Recurrence.new(every: :month, mday: 31, until: "January 1, 2017")
r.each { |time| puts time.to_s }

# Merging rules and enumerating
r.merge(starts: "2017-01-01").each { |time| puts time.to_s }
r.merge(starts: "2017-01-01").each { |date| puts date.to_s }
r.merge(until: "2017-01-10").each { |date| puts date.to_s }
r.merge(through: "2017-01-10").each { |date| puts date.to_s }
r.merge(starts: "2017-01-05", until: "2017-01-10").each {|date| puts date.to_s }

# Using #events Enumerator
r.events # => #<Enumerator: ...>
r.events.take(10).each { |date| puts date.to_s }
r.events.lazy.select { |time| time > 1.month.from_now }.take(3).each { |date| puts date.to_s }
```

## Goals

`Montrose` aims to provide a simple interface for specifying and enumerating recurring events as Time objects. To that end, the project intends to:

* embrace Ruby idioms
* support Ruby 2.1+
* be reasonably performant
* serialize to yaml, hash, and [ical](http://www.kanzaki.com/docs/ical/rrule.html#basic) formats
* be suitable for integration with persistence libraries

What `Montrose` isn't:

* support all calendaring use cases under the sun

### Inspiration

Montrose is named after the beautifully diverse and artistic [neighborhood in Houston, Texas](https://en.wikipedia.org/wiki/Montrose,_Houston).

## Related Projects

Check out following related projects, all of which have provided inspiration for `Montrose`.

* [recurrence](https://github.com/fnando/recurrence)
* [ice_cube](https://github.com/seejohnrun/ice_cube)
* [runt](https://github.com/mlipper/runt)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rossta/montrose. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
