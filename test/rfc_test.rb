require "test_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  before do
    Timecop.freeze(Time.now)
  end

  it "supports daily for 10 occurrences" do
    schedule = new_schedule

    count = 10
    schedule << { every: :day, repeat: count }

    starts_at = Time.parse("September 20, 2015 9:00 AM EDT")

    dates = schedule.events(starts: starts_at).to_a

    assert_pairs_with consecutive_days(count, starts: starts_at), dates

    dates.size.must_equal count
  end

  it "supports daily until December 24, 2015" do
    schedule = new_schedule

    until_on = Date.parse("December 24, 2015")
    starts_on = Date.parse("December 20, 2015")
    count = 5

    schedule << { every: :day, until: until_on }

    expected_dates = consecutive_days(count, starts: starts_on)
    dates = schedule.events(starts: starts_on).to_a

    assert_pairs_with expected_dates, dates

    dates.size.must_equal count
  end

  it "supports every other day - forever" do
    schedule = new_schedule

    schedule << { every: :day, interval: 2 }

    expected_dates = consecutive_days(5)
    dates = schedule.events.take(5)

    assert_pairs_with expected_dates, dates
  end
end
