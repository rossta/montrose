require "spec_helper"

describe "RFC Recurrence Rules" do # http://www.kanzaki.com/docs/ical/rrule.html
  let(:time_now) { Time.parse("Tuesday, September 1, 2015, 12:00 PM") }

  before do
    Timecop.freeze(time_now)
  end

  it "daily for 10 occurrences" do
    schedule = new_schedule every: :day, repeat: 10

    dates = schedule.events(starts: time_now).to_a

    dates.must_pair_with consecutive_days(10, starts: time_now)
    dates.size.must_equal 10
  end

  it "daily until December 23, 2015" do
    starts_on = time_now.to_date
    ends_on = Date.parse("December 23, 2015")
    days = starts_on.upto(ends_on).count - 1

    schedule = new_schedule every: :day, until: ends_on

    expected_dates = consecutive_days(days, starts: starts_on)
    dates = schedule.events(starts: starts_on).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal days
  end

  it "every other day forever" do
    schedule = new_schedule every: :day, interval: 2

    expected_dates = consecutive_days(5, interval: 2)
    dates = schedule.events.take(5)

    dates.must_pair_with expected_dates
  end

  it "every 10 days 5 occurrences" do
    schedule = new_schedule every: :day, interval: 10, repeat: 5

    expected_dates = consecutive_days(5, interval: 10)
    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 5
  end

  describe "everyday in January for 3 years" do
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

  it "weekly for 10 occurrences" do
    schedule = new_schedule(every: :week, repeat: 10)

    expected_dates = consecutive(:weeks, 10)
    dates = schedule.events.take(10)

    dates.must_pair_with expected_dates
  end

  it "weekly until December 23, 2015" do
    ends_on = Date.parse("December 23, 2015")
    starts_on = ends_on - 15.weeks

    schedule = new_schedule every: :week, until: ends_on

    expected_dates = consecutive(:weeks, 15, starts: starts_on)
    dates = schedule.events(starts: starts_on).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 15
  end

  it "every other week forever" do
    schedule = new_schedule every: :week, interval: 2

    expected_dates = consecutive(:weeks, 5, interval: 2)
    dates = schedule.events.take(5)

    dates.must_pair_with expected_dates
  end

  describe "Tues/Thurs for 5 weeks" do
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

  it "every other week on Monday, Wednesday and Friday until December 23 2015,
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

  it "every other week on Tuesday and Thursday, for 8 occurrences" do
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

  it "monthly on the 1st Friday for ten occurrences" do
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

  it "monthly on the 1st Friday until December 23, 2015" do
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

  it "every other month on the 1st and last Sunday of the month for 10 occurrences" do
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
    schedule = new_schedule(every: :month, mday: [-3])

    expected_dates = cherry_pick(
      2015 => { 9 => [28], 10 => [29], 11 => [28], 12 => [29] },
      2016 => { 1 => [29], 2 => [27] }).map { |t| t + 12.hours }

    dates = schedule.events.take(6)

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "monthly on the 2nd and 15th of the month for 10 occurrences" do
    schedule = new_schedule(every: :month, mday: [2, 15], total: 10)

    expected_dates = cherry_pick(
      2015 => { 9 => [2, 15], 10 => [2, 15], 11 => [2, 15], 12 => [2, 15] },
      2016 => { 1 => [2, 15] }).map { |t| t + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "monthly on the first and last day of the month for 10 occurrences" do
    starts = Date.parse("Tuesday, September 2, 2015")
    schedule = new_schedule(starts: starts, every: :month, mday: [1, -1], total: 10)

    expected_dates = cherry_pick(
      2015 => { 9 => [30], 10 => [1, 31], 11 => [1, 30], 12 => [1, 31] },
      2016 => { 1 => [1, 31], 2 => [1] })

    dates = schedule.events(starts: starts).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "every 18 months on the 10th thru 15th of the month for 10 occurrences" do
    starts = Date.parse("September 1, 2015")
    schedule = new_schedule(starts: starts, every: :month, interval: 18, total: 10, mday: 10..15)

    expected_dates = cherry_pick(
      2015 => { 9 => [10, 11, 12, 13, 14, 15] },
      2017 => { 3 => [10, 11, 12, 13] })

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "every Tuesday, every other month" do
    starts = Date.parse("September 1, 2015")
    schedule = new_schedule(every: :month, interval: 2, day: :tuesday)

    expected_dates = cherry_pick(
      2015 => { 9 => [1, 8, 15, 22, 29], 11 => [3, 10, 17, 24] },
      2016 => { 1 => [5, 12, 19, 26], 3 => [1, 8, 15, 22, 29] })

    dates = schedule.events(starts: starts).take(expected_dates.size)

    dates.must_pair_with expected_dates
  end

  it "yearly in June and July for 10 occurrences" do
    schedule = new_schedule(every: :year, month: [:june, :july], total: 10)

    expected_dates = cherry_pick(
      2016 => { 6 => [1], 7 => [1] },
      2017 => { 6 => [1], 7 => [1] },
      2018 => { 6 => [1], 7 => [1] },
      2019 => { 6 => [1], 7 => [1] },
      2020 => { 6 => [1], 7 => [1] }).map { |i| i + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 10
  end

  it "every other year on January, February, and March for 10 occurrences" do
    starts = Time.parse("March 10, 2015")
    schedule = new_schedule(
      every: :year,
      month: [:january, :february, :march],
      interval: 2,
      total: 10)

    expected_dates = cherry_pick(
      2015 => { 3 => [10] },
      2017 => { 1 => [10], 2 => [10], 3 => [10] },
      2019 => { 1 => [10], 2 => [10], 3 => [10] },
      2021 => { 1 => [10], 2 => [10], 3 => [10] })

    dates = schedule.events(starts: starts).to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 10
  end

  it "every 3rd year on the 1st, 100th and 200th day for 10 occurrences" do
    schedule = new_schedule(
      every: :year,
      yday: [1, 100, 200],
      total: 10)

    expected_dates = cherry_pick(
      2016 => { 1 => [1], 4 => [9], 7 => [18] },
      2017 => { 1 => [1], 4 => [10], 7 => [19] },
      2018 => { 1 => [1], 4 => [10], 7 => [19] },
      2019 => { 1 => [1] }).map { |i| i + 12.hours }

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal 10
  end

  it "every 20th Monday of the year, forever" do
    schedule = new_schedule(every: :year, day: { monday: [20] })

    expected_dates = cherry_pick(
      2016 => { 5 => [16] },
      2017 => { 5 => [15] },
      2018 => { 5 => [14] }).map { |i| i + 12.hours }

    dates = schedule.events.take(3)
    dates.must_pair_with expected_dates
  end

  it "Monday of week number 20 forever" do
    schedule = new_schedule(every: :year, week: [20], day: [:monday])

    expected_dates = cherry_pick(
      2016 => { 5 => [16] },
      2017 => { 5 => [15] },
      2018 => { 5 => [14] }).map { |i| i + 12.hours }

    dates = schedule.events.take(3)

    dates.must_pair_with expected_dates
  end

  it "every Thursday in March, forever" do
    starts = Time.parse("March 10, 2016 12:00 PM")
    schedule = new_schedule(every: :year, month: :march, day: :thursday)

    expected_dates = cherry_pick(
      2016 => { 3 => [10, 17, 24, 31] },
      2017 => { 3 => [2, 9, 16, 23, 30] },
      2018 => { 3 => [1, 8, 15, 22, 29] }).map { |i| i + 12.hours }

    dates = schedule.events(starts: starts).take(expected_dates.size)
    dates.must_pair_with expected_dates
  end

  it "every Thursday, but only during June, July, and August, forever" do
    schedule = new_schedule(every: :year, month: 6..8, day: :thursday)

    expected_dates = cherry_pick(
      2016 => { 6 => [2, 9, 16, 23, 30], 7 => [7, 14, 21, 28], 8 => [4, 11, 18, 25] },
      2017 => { 6 => [1, 8, 15, 22, 29], 7 => [6, 13, 20, 27], 8 => [3, 10, 17, 24, 31] },
      2018 => { 6 => [7, 14, 21, 28], 7 => [5, 12, 19, 26], 8 => [2, 9, 16, 23, 30] }).map { |i| i + 12.hours }

    dates = schedule.events.take(expected_dates.size)

    dates.must_pair_with expected_dates
  end

  it "every Friday 13th forever" do
    schedule = new_schedule(every: :month, mday: 13, day: :friday)

    expected_dates = cherry_pick(
      2015 => { 11 => [13] },
      2016 => { 5 => [13] },
      2017 => { 1 => [13], 10 => [13] },
      2018 => { 4 => [13], 7 => [13] }).map { |i| i + 12.hours }

    dates = schedule.events.take(expected_dates.size)

    dates.must_pair_with expected_dates
  end

  it "first Saturday that follows the first Sunday of the month, forever" do
    schedule = new_schedule(every: :month, mday: 7..13, day: :saturday)

    expected_dates = cherry_pick(
      2015 => { 9 => [12], 10 => [10], 11 => [7], 12 => [12] },
      2016 => { 1 => [9], 2 => [13], 3 => [12], 4 => [9], 5 => [7], 6 => [11] }
    ).map { |i| i + 12.hours }

    dates = schedule.events.take(expected_dates.size)

    dates.must_pair_with expected_dates
  end

  it "every four years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)" do
    Timecop.travel(Date.parse("January 1, 2016"))
    schedule = new_schedule(every: :year, interval: 4, month: :november, day: :tuesday, mday: 2..8)

    expected_dates = cherry_pick(
      2016 => { 11 => [8] },
      2020 => { 11 => [3] },
      2024 => { 11 => [5] })

    dates = schedule.events.take(expected_dates.size)

    dates.must_pair_with expected_dates
  end

  # TODO: - Support set position
  # "3rd instance into the month of one of Tuesday, Wednesday or Thursday, for the next 3 months" do
  # i.e., every: :month, repeat: 3, day: [:tuesday, :wednesday, :thursday], pos: 3
  # "2nd to last weekday of the month"
  # i.e., every: :month, repeat: 3, day: [:monday, tuesday, :wednesday, :thursday, :friday], pos: -2

  it "every 3 hours from 9:00 AM to 5:00 PM on a specific day" do
    starts = Time.parse("September 1, 2015 9:00 AM")
    ends = Time.parse("September 1, 2015 5:00 PM")
    schedule = new_schedule(every: :hour, interval: 3, starts: starts, until: ends)

    expected_dates = consecutive(:hours, 3, starts: starts, interval: 3)

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
    dates.size.must_equal expected_dates.size
  end

  it "every 15 minutes for 6 occurrences" do
    schedule = new_schedule(every: :minute, interval: 15, total: 6)

    expected_dates = consecutive(:minutes, 6, interval: 15)

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
  end

  it "every hour and a half for four occurrences" do
    schedule = new_schedule(every: :minute, interval: 90, total: 4)

    expected_dates = consecutive(:minutes, 4, interval: 90)

    dates = schedule.events.to_a

    dates.must_pair_with expected_dates
  end

  it "every 20 minutes from 9:00 AM to 4:40 PM every day" do
    Timecop.freeze(time_now.beginning_of_day)
    schedule = new_schedule(every: :minute, interval: 20, hour: 9..16)

    expected_dates = consecutive(:minute, 24, starts: Time.parse("September 1, 2015 9:00 AM"), interval: 20)
    expected_dates += consecutive(:minute, 24, starts: Time.parse("September 2, 2015 9:00 AM"), interval: 20)
    expected_dates += consecutive(:minute, 24, starts: Time.parse("September 3, 2015 9:00 AM"), interval: 20)

    dates = schedule.events.take(72)

    dates.must_pair_with expected_dates
  end
end
