require "test_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  before do
    Timecop.freeze(Time.now)
  end

  it "supports daily for 10 occurrences" do
    starts_at = Time.parse("September 20, 2015 9:00 AM EDT")

    schedule = new_schedule every: :day, repeat: 10

    dates = schedule.events(starts: starts_at).to_a

    dates.must_pair_with consecutive_days(10, starts: starts_at)
    dates.size.must_equal 10
  end

  it "supports daily until December 24, 2015" do
    ends_on = Date.parse("December 24, 2015")
    starts_on = Date.parse("December 20, 2015")
    days = starts_on.upto(ends_on).count

    schedule = new_schedule every: :day, until: ends_on

    expected_dates = consecutive_days(days, starts: starts_on)
    dates = schedule.events(starts: starts_on).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal days
  end

  it "supports every other day forever" do
    schedule = new_schedule every: :day, interval: 2

    expected_dates = consecutive_days(5, interval: 2)
    dates = schedule.events.take(5)

    dates.must_pair_with expected_dates
  end

  it "supports every 10 days 5 occurrences" do
    schedule = new_schedule every: :day, interval: 10, repeat: 5

    expected_dates = consecutive_days(5, interval: 10)
    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 5
  end

  describe "supports everyday in January for 3 years" do
    let(:starts_at) { Time.local(2016, 1, 1) }
    let(:ends_at) { (starts_at + 2.years).end_of_month }

    let(:expected_dates) do
      consecutive_days(31, starts: starts_at) +
        consecutive_days(31, starts: starts_at + 1.year) +
        consecutive_days(31, starts: starts_at + 2.years)
    end

    before do
      Timecop.freeze(starts_at - 1.day)
    end

    it "daily" do
      schedule = new_schedule(every: :day, month: :january, until: ends_at)

      dates = schedule.events.to_a

      dates.must_pair_with expected_dates
      dates.size.must_equal 31 * 3
    end

    it "yearly" do
      schedule = new_schedule(
        every: :year,
        month: :january,
        day: [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday],
        until: ends_at)

      dates = schedule.events.to_a

      dates.must_pair_with expected_dates
      dates.size.must_equal 31 * 3
    end
  end
end
