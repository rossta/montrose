require "test_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  it "supports daily for 10 occurrences" do
    schedule = new_schedule

    count = 10
    schedule << { every: :day, repeat: count }

    starts_at = Time.parse("September 20, 2015 9:00 AM EDT")

    dates = schedule.events(starts: starts_at).to_a

    expected_dates = [].tap do |e|
      date = starts_at
      count.times do
        e << date
        date += 1.day
      end
    end

    expected_dates.zip(dates).each do |expected, date|
      date.must_equal expected
    end

    dates.size.must_equal count
  end

  it "supports daily until December 24, 2015" do
    schedule = new_schedule

    until_on = Date.parse("December 24, 2015")
    starts_on = Date.parse("December 20, 2015")
    count = 5

    schedule << { every: :day, until: until_on }

    expected_dates = [].tap do |e|
      date = starts_on.to_time
      count.times do
        e << date
        date += 1.day
      end
    end

    dates = schedule.events(starts: starts_on).to_a

    expected_dates.zip(dates).each do |expected, date|
      date.must_equal expected
    end

    dates.size.must_equal count
  end

  it "supports every other day - forever" do
    schedule = new_schedule

    starts_on = Date.parse("December 31, 2015")
    count = 5

    schedule << { every: :day, interval: 2 }

    expected_dates = [].tap do |e|
      date = starts_on.to_time
      count.times do
        e << date
        date += 1.day
      end
    end

    dates = schedule.events(starts: starts_on).take(5).to_a

    expected_dates.zip(dates).each do |expected, date|
      date.must_equal expected
    end
  end
end
