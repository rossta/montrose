require "test_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  it "is daily for 10 occurrences" do
    schedule = new_schedule

    schedule << { every: :day, repeat: 10 }

    starts = Time.parse("September 20, 2015 9:00 AM EDT")

    dates = schedule.events(starts: starts).to_a

    expected_date = starts
    expected_dates = [].tap do |e|
      10.times do
        e << expected_date
        expected_date += 1.day
      end
    end

    expected_dates.zip(dates).each do |expected, date|
      date.must_equal expected
    end

    dates.size.must_equal 10
  end
end
