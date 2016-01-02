require "test_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  let(:time_now) { Time.parse("Tuesday, September 1, 2015, 12:00 PM") }

  before do
    Timecop.freeze(time_now)
  end

  it "supports daily for 10 occurrences" do
    schedule = new_schedule every: :day, repeat: 10

    dates = schedule.events(starts: time_now).to_a

    dates.must_pair_with consecutive_days(10, starts: time_now)
    dates.size.must_equal 10
  end

  it "supports daily until December 23, 2015" do
    starts_on = time_now.to_date
    ends_on = Date.parse("December 23, 2015")
    days = starts_on.upto(ends_on).count - 1

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
    let(:starts_at) { Time.parse("January 1, 2016, 9:00 AM") }
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

  it "supports weekly for 10 occurrences" do
    schedule = new_schedule(every: :week, repeat: 10)

    expected_dates = consecutive(:weeks, 10)
    dates = schedule.events.take(10)

    dates.must_pair_with expected_dates
  end

  it "supports weekly until December 23, 2015" do
    ends_on = Date.parse("December 23, 2015")
    starts_on = ends_on - 15.weeks

    schedule = new_schedule every: :week, until: ends_on

    expected_dates = consecutive(:weeks, 15, starts: starts_on)
    dates = schedule.events(starts: starts_on).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 15
  end

  it "supports every other week forever" do
    schedule = new_schedule every: :week, interval: 2

    expected_dates = consecutive(:weeks, 5, interval: 2)
    dates = schedule.events.take(5)

    dates.must_pair_with expected_dates
  end

  describe "supports Tues/Thurs for 5 weeks" do
    it "until end date" do
      schedule = new_schedule(
        every: :week,
        day: [:tuesday, :thursday],
        starts: Date.parse("September 1, 2015"),
        until: Date.parse("October 5, 2015"))

      expected_dates = cherry_pick 2015 => { 9 => [1, 3, 8, 10, 15, 17, 22, 24, 29], 10 => [1] }
      dates = schedule.events.to_a

      dates.must_pair_with expected_dates
      dates.size.must_equal 10
    end

    it "by count" do
      schedule = new_schedule(
        every: :week,
        day: [:tuesday, :thursday],
        starts: Date.parse("Nov 22, 2015"),
        repeat: 5)

      expected_dates = cherry_pick 2015 => { 11 => [24, 26], 12 => [1, 3, 8, 10, 15, 17, 22, 24] }
      dates = schedule.events.to_a

      dates.must_pair_with expected_dates
      dates.size.must_equal 10
    end
  end

  it "supports every other week on Monday, Wednesday and Friday until December 23 2015,
    but starting on Tuesday, September 1, 2015" do
    schedule = new_schedule(
      every: :week,
      day: [:monday, :wednesday, :friday],
      starts: Date.parse("September 1, 2015"),
      until: Date.parse("December 23, 2015"),
      interval: 2)

    # September 1 is omitted for now: need to implement OR interval grouping
    expected_dates = cherry_pick 2015 => {
      9 => [2, 4, 14, 16, 18, 28, 30],
      10 => [2, 12, 14, 16, 26, 28, 30],
      11 => [9, 11, 13, 23, 25, 27],
      12 => [7, 9, 11, 21]
    }
    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "supports every other week on Tuesday and Thursday, for 8 occurrences" do
    schedule = new_schedule(
      every: :week,
      day: [:tuesday, :thursday],
      starts: Date.parse("September 1, 2015"),
      until: Date.parse("December 23, 2015"),
      total: 8,
      interval: 2)

    expected_dates = cherry_pick 2015 => { 9 => [1, 3, 15, 17, 29], 10 => [1, 13, 15] }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "supports monthly on the 1st Friday for ten occurrences" do
    schedule = new_schedule(
      every: :month,
      day: { friday: [1] },
      total: 10)

    expected_dates = cherry_pick(
      2015 => { 9 => [4], 10 => [2], 11 => [6], 12 => [4] },
      2016 => { 1 => [1], 2 => [5], 3 => [4], 4 => [1], 5 => [6], 6 => [3] }
    ).map { |t| t + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "supports monthly on the 1st Friday until December 23, 2015" do
    schedule = new_schedule(
      every: :month,
      day: { friday: [1] },
      until: Date.parse("December 23, 2015"))

    expected_dates = cherry_pick(
      2015 => { 9 => [4], 10 => [2], 11 => [6], 12 => [4] }
    ).map { |t| t + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "supports every other month on the 1st and last Sunday of the month for 10 occurrences" do
    starts = Date.parse("Tuesday, September 1, 2015")
    Timecop.travel(starts) # Make it easier to set up expected dates for this test

    schedule = new_schedule(
      every: :month,
      start: starts,
      day: { sunday: [1, -1] },
      interval: 2,
      total: 10)

    expected_dates = cherry_pick(
      2015 => { 9 => [6, 27], 11 => [1, 29] },
      2016 => { 1 => [3, 31], 3 => [6, 27], 5 => [1, 29] }
    )

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "monthly on the second to last Monday of the month for 6 months" do
    schedule = new_schedule(
      every: :month,
      day: { monday: [-2] },
      repeat: 6)

    expected_dates = cherry_pick(
      2015 => { 9 => [21], 10 => [19], 11 => [23], 12 => [21] },
      2016 => { 1 => [18], 2 => [22] }).map { |t| t + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "monthly on the third to the last day of the month, forever" do
    schedule = new_schedule(every: :month, day: [-3])

    expected_dates = cherry_pick(
      2015 => { 9 => [28], 10 => [29], 11 => [28], 12 => [29] },
      2016 => { 1 => [29], 2 => [27] }).map { |t| t + 12.hours }

    dates = schedule.events.take(6)

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end
end
