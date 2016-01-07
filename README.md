# Montrose

Recurring events in Ruby.

This library is currently under development. Most of the functionality does not
exist yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'montrose'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install montrose

## Usage

```ruby
require "montrose"

# Seconds
Montrose::Recurrence.new(every: :second)
Montrose::Recurrence.new(every: :second, interval: 30)
Montrose::Recurrence.new(every: 30.seconds)

# Minutely
Montrose::Recurrence.new(every: :minute, interval: 10)
Montrose::Recurrence.new(every: 10.minutes)

# Daily
Montrose::Recurrence.new(every: :day)
Montrose::Recurrence.new(every: :day, interval: 9)
Montrose::Recurrence.new(every: :day, repeat: 7)
Montrose::Recurrence.new(every: :day, at: "9:00 AM")
Montrose::Recurrence.daily(options = {})

# Weekly
Montrose::Recurrence.new(every: :week, on: 5)
Montrose::Recurrence.new(every: :week, on: :monday)
Montrose::Recurrence.new(every: :week, on: [:monday, :wednesday, :friday])
Montrose::Recurrence.new(every: :week, on: :friday, interval: 2)
Montrose::Recurrence.new(every: :week, on: :friday, repeat: 4)
Montrose::Recurrence.new(every: :week, on: :friday, at: "3:41 PM")
Montrose::Recurrence.new(every: :week, on: [:monday, :wednesday, :friday], at: "12:00 PM")
Montrose::Recurrence.weekly(on: :thursday)

# Monthly by month day
Montrose::Recurrence.new(every: :month, on: 15)
Montrose::Recurrence.new(every: :month, on: 31)
Montrose::Recurrence.new(every: :month, on: 7, interval: 2)
Montrose::Recurrence.new(every: :month, on: 7, interval: :monthly)
Montrose::Recurrence.new(every: :month, on: 7, interval: :bimonthly)
Montrose::Recurrence.new(every: :month, on: 7, repeat: 6)
Montrose::Recurrence.monthly(on: 31)

# Monthly by week day
Montrose::Recurrence.new(every: :month, on: :first, weekday: :sunday)
Montrose::Recurrence.new(every: :month, on: :third, weekday: :monday)
Montrose::Recurrence.new(every: :month, on: :last,  weekday: :friday)
Montrose::Recurrence.new(every: :month, on: :last,  weekday: :friday, interval: 2)
Montrose::Recurrence.new(every: :month, on: :last,  weekday: :friday, interval: :quarterly)
Montrose::Recurrence.new(every: :month, on: :last,  weekday: :friday, interval: :semesterly)
Montrose::Recurrence.new(every: :month, on: :last,  weekday: :friday, repeat: 3)

# Yearly
Montrose::Recurrence.new(every: :year, on: [7, 4]) # => [month, day]
Montrose::Recurrence.new(every: :year, on: [10, 31], interval: 3)
Montrose::Recurrence.new(every: :year, on: [:jan, 31])
Montrose::Recurrence.new(every: :year, on: [:january, 31])
Montrose::Recurrence.new(every: :year, on: [10, 31], repeat: 3)
Montrose::Recurrence.yearly(on: [:january, 31])

# Limit recurrence
# :starts defaults to Date.today
# :until defaults to 2037-12-31
Montrose::Recurrence.new(every: :day, starts: Date.today)
Montrose::Recurrence.new(every: :day, until: '2010-01-31')
Montrose::Recurrence.new(every: :day, starts: Date.today, until: '2010-01-31')

# Generate a collection of events which always includes a final event with the given through date
# :through defaults to being unset
Montrose::Recurrence.new(every: :day, through: '2010-01-31')
Montrose::Recurrence.new(every: :day, starts: Date.today, through: '2010-01-31')

# Remove a date in the series on the given except date(s)
# :except defaults to being unset
Montrose::Recurrence.new(every: :day, except: '2010-01-31')
Montrose::Recurrence.new(every: :day, except: [Date.today, '2010-01-31'])

# Override the next date handler
s = Montrose::Recurrence.new(every: :month, on: 1, handler: Proc.new { |day, month, year| raise("Date not allowed!") if year == 2011 && month == 12 && day == 31 })

# Shift the recurrences to maintain dates around boundaries (Jan 31 -> Feb 28 -> Mar 28)
r = Montrose::Recurrence.new(every: :month, on: 31, shift: true)

# Getting an array with all events
r.events.each {|date| puts date.to_s }  # => Memoized array
r.events!.each {|date| puts date.to_s } # => reset items cache and re-execute it
r.events(starts: '2009-01-01').each {|date| puts date.to_s }
r.events(until: '2009-01-10').each {|date| puts date.to_s }
r.events(through: '2009-01-10').each {|date| puts date.to_s }
r.events(starts: '2009-01-05', until: '2009-01-10').each {|date| puts date.to_s }

# Iterating events
r.each { |date| puts date.to_s } # => Use items method
r.each! { |date| puts date.to_s } # => Use items! method

# Check if a date is included
r.include?(Date.today) # => true or false
r.include?('2008-09-21')

# Get next available date
r.next  # => Keep the original date object
r.next! # => Change the internal date object to the next available date
```

## Goals

What `Montrose` intends to be:

* embraces Ruby idioms
* simple to use interface
* reasonably performant
* serializable to yaml, hash, and [ical](http://www.kanzaki.com/docs/ical/rrule.html#basic) formats
* suitable for integration with persistence libraries
* supports Ruby 2.1+

What `Montrose` isn't:

* support all calendaring use cases under the sun

## TODO

- [ ] Support `:at` option and chainable method for time of day string, e.g. `at: '7:00 pm'`
- [ ] Support `:between` option and chainable method for date range, e.g.
  `between: (today..tomorrow)`

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
