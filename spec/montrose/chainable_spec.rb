# frozen_string_literal: true

require "spec_helper"

describe Montrose::Chainable do
  let(:now) { Time.local(2015, 9, 1, 12) } # Tuesday

  before do
    Timecop.freeze(now)
  end

  describe "#every" do
    it "returns recurrence" do
      recurrence = Montrose.every(:minute)
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits given frequency default" do
      recurrence = Montrose.every(:minute)
      recurrence.events.must_have_interval 1.minute

      recurrence = Montrose.every(2.hours)
      recurrence.events.must_have_interval 2.hours
    end

    it "accepts options" do
      recurrence = Montrose.every(:minute, total: 2)
      recurrence.events.to_a.size.must_equal 2
    end
  end

  describe "#minutely" do
    it "returns recurrence" do
      recurrence = Montrose.minutely
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per hour by default" do
      recurrence = Montrose.minutely
      recurrence.events.must_have_interval 1.minute
    end
  end

  describe "#hourly" do
    it "returns recurrence" do
      recurrence = Montrose.hourly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per hour by default" do
      recurrence = Montrose.hourly
      recurrence.events.must_have_interval 1.hour
    end
  end

  describe "#daily" do
    it "returns recurrence" do
      recurrence = Montrose.daily
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per day by default" do
      recurrence = Montrose.daily
      recurrence.events.must_have_interval 1.day
    end
  end

  describe "#weekly" do
    it "returns recurrence" do
      recurrence = Montrose.weekly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per week by default" do
      recurrence = Montrose.weekly
      recurrence.events.must_have_interval 1.week
    end
  end

  describe "#monthly" do
    it "returns recurrence" do
      recurrence = Montrose.daily
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per week by default" do
      recurrence = Montrose.monthly
      recurrence.events.must_have_interval 1.month
    end
  end

  describe "#yearly" do
    it "returns recurrence" do
      recurrence = Montrose.yearly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per year by default" do
      recurrence = Montrose.yearly
      recurrence.events.must_have_interval((now + 1.year) - now)
    end
  end

  describe "#starting" do
    it "returns new recurrence starting at given time" do
      recurrence = Montrose.daily.starting(3.days.from_now)

      recurrence.events.first.must_equal 3.days.from_now
    end
  end

  describe "#ending" do
    it "returns new recurrence ending before given time" do
      recurrence = Montrose.daily.ending(3.days.from_now + 1.minute)

      recurrence.events.to_a.last.must_equal 3.days.from_now
    end
  end

  describe "#between" do
    let(:starts) { now }
    let(:ends) { 3.days.from_now }

    it "returns recurrence" do
      recurrence = Montrose.hourly.between(starts...ends)
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "specifies start and end" do
      recurrence = Montrose.hourly.between(starts...ends)
      events = recurrence.events.to_a
      events.first.must_equal starts
      events.last.must_equal ends
    end
  end

  describe "#covering" do
    let(:from) { 1.day.from_now.to_date }
    let(:to) { 3.days.from_now.to_date }

    it "returns recurrence" do
      recurrence = Montrose.hourly.covering(from...to)
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "specifies start and end of mask" do
      recurrence = Montrose.hourly.covering(from...to)
      events = recurrence.events.to_a
      events.first.must_equal(Time.local(2015, 9, 2, 0, 0, 0))
      events.last.must_equal(Time.local(2015, 9, 3, 23, 0, 0))
    end
  end

  describe "#during" do
    let(:now) { Time.local(2015, 9, 1, 6, 0, 0) }

    it "returns recurrence" do
      recurrence = Montrose.every(20.minutes).during("9am-10am")
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits within given time-of-day range" do
      recurrence = Montrose.every(20.minutes).during("9am-10am")
      recurrence.events.must_pair_with [
        Time.local(2015, 9, 1, 9, 0, 0),
        Time.local(2015, 9, 1, 9, 20, 0),
        Time.local(2015, 9, 1, 9, 40, 0),
        Time.local(2015, 9, 1, 10, 0, 0)
      ]
    end

    it "emits within given time-of-day range" do
      recurrence = Montrose.every(20.minutes).during("9am-10am")
      recurrence.events.must_pair_with [
        Time.local(2015, 9, 1, 9, 0, 0),
        Time.local(2015, 9, 1, 9, 20, 0),
        Time.local(2015, 9, 1, 9, 40, 0),
        Time.local(2015, 9, 1, 10, 0, 0)
      ]
    end
  end

  describe "#day_of_month" do
    it "returns new recurrence by given days of month" do
      recurrence = Montrose.monthly.starting(Time.local(2016, 1, 2))
      recurrence = recurrence.day_of_month(1, -1)

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 31),
        Time.local(2016, 2, 1),
        Time.local(2016, 2, 29),
        Time.local(2016, 3, 1)
      ]
    end
  end

  describe "#day_of_week" do
    it "returns new recurrence by given days of month" do
      recurrence = Montrose.weekly
      recurrence = recurrence.day_of_week(:sunday, :saturday)

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 5, 12),
        Time.local(2015, 9, 6, 12)
      ]

      Time.local(2015, 9, 5, 12).wday.must_equal 6
      Time.local(2015, 9, 6, 12).wday.must_equal 0
    end

    it "returns new recurrence by given range of days" do
      recurrence = Montrose.weekly
      recurrence = recurrence.day_of_week(1..3)

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 1, 12), # Tuesday
        Time.local(2015, 9, 2, 12),
        Time.local(2015, 9, 7, 12)
      ]
    end

    it "handles hash arg for ordinal number" do
      recurrence = Montrose.monthly
      recurrence = recurrence.day_of_week(tuesday: [2]) # 2nd Tuesday of month

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 8, 12), # Tuesday
        Time.local(2015, 10, 13, 12),
        Time.local(2015, 11, 10, 12)
      ]
    end
  end

  describe "#day_of_year" do
    it "returns new recurrence by given days of year" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_year(1, 10, 100)

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 1, 10, 12),
        Time.local(2016, 4, 9, 12), # 100th day
        Time.local(2017, 1, 1, 12)
      ]
    end

    it "returns new recurrence by given array of days" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_year([1, 10, 100])

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 1, 10, 12),
        Time.local(2016, 4, 9, 12), # 100th day
        Time.local(2017, 1, 1, 12)
      ]
    end

    it "returns new recurrence by given range of days" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_year(98..100)

      recurrence.events.must_pair_with [
        Time.local(2016, 4, 7, 12),
        Time.local(2016, 4, 8, 12),
        Time.local(2016, 4, 9, 12), # 100th day
        Time.local(2017, 4, 8, 12)
      ]
    end
  end

  describe "#hour_of_day" do
    it "returns new recurrence by given hours of day" do
      recurrence = Montrose.daily
      recurrence = recurrence.hour_of_day(6, 7, 8)

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 2, 6),
        Time.local(2015, 9, 2, 7),
        Time.local(2015, 9, 2, 8),
        Time.local(2015, 9, 3, 6)
      ]
    end

    it "returns new recurrence by given array of hours" do
      recurrence = Montrose.daily
      recurrence = recurrence.hour_of_day([6, 7, 8])

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 2, 6),
        Time.local(2015, 9, 2, 7),
        Time.local(2015, 9, 2, 8),
        Time.local(2015, 9, 3, 6)
      ]
    end

    it "returns new recurrence by given range of hours" do
      recurrence = Montrose.daily
      recurrence = recurrence.hour_of_day(6..8)

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 2, 6),
        Time.local(2015, 9, 2, 7),
        Time.local(2015, 9, 2, 8),
        Time.local(2015, 9, 3, 6)
      ]
    end
  end

  describe "#month_of_year" do
    it "returns new recurrence by given month of year" do
      recurrence = Montrose.yearly
      recurrence = recurrence.month_of_year(:january, :april)

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 4, 1, 12),
        Time.local(2017, 1, 1, 12)
      ]
    end

    it "returns new recurrence by given array of months" do
      recurrence = Montrose.yearly
      recurrence = recurrence.month_of_year([:january, :april])

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 4, 1, 12),
        Time.local(2017, 1, 1, 12)
      ]
    end

    it "returns new recurrence by given range of months" do
      recurrence = Montrose.yearly
      recurrence = recurrence.month_of_year(1..3)

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 2, 1, 12),
        Time.local(2016, 3, 1, 12),
        Time.local(2017, 1, 1, 12)
      ]
    end
  end

  describe "#total" do
    it "returns new recurrence for maximum total" do
      recurrence = Montrose.yearly
      recurrence = recurrence.total(3)

      events = recurrence.events.to_a
      events.must_pair_with [
        Time.local(2015, 9, 1, 12),
        Time.local(2016, 9, 1, 12),
        Time.local(2017, 9, 1, 12)
      ]

      events.size.must_equal 3
    end
  end

  describe "#week_of_year" do
    it "returns new recurrence by given week of year" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_week(:monday).week_of_year(1, 52)

      recurrence.events.must_pair_with [
        Time.local(2015, 12, 21, 12), # Monday, 52nd week
        Time.local(2016, 1, 4, 12) # Monday, 1st week
      ]
    end

    it "returns new recurrence by given range of weeks" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_week(:monday).week_of_year(50..52)

      recurrence.events.must_pair_with [
        Time.local(2015, 12, 7, 12),
        Time.local(2015, 12, 14, 12),
        Time.local(2015, 12, 21, 12) # Monday, 52nd week
      ]
    end
  end

  describe "#on" do
    it "returns new recurrence on given day" do
      recurrence = Montrose.weekly
      recurrence = recurrence.on(:monday)

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 7, 12),
        Time.local(2015, 9, 14, 12),
        Time.local(2015, 9, 21, 12)
      ]
    end
  end

  describe "#at" do
    it "returns new recurrence at given time" do
      recurrence = Montrose.daily
      recurrence = recurrence.at("4:05pm")

      recurrence.events.must_pair_with [
        Time.local(2015, 9, 1, 16, 5),
        Time.local(2015, 9, 2, 16, 5),
        Time.local(2015, 9, 3, 16, 5)
      ]
    end
  end

  describe "#except" do
    it "returns recurrence without specific dates" do
      recurrence = Montrose.daily
      recurrence = recurrence.except([Date.today, Date.today + 7.days])

      dates = recurrence.take(10).map(&:to_date)

      assert dates.include?(Date.today + 1.day),
        "dates should include #{Date.today + 1.day}"
      refute dates.include?(Date.today),
        "dates shouldn't include #{Date.today}"
      refute dates.include?(Date.today + 7.days),
        "dates shouldn't include #{Date.today + 7.days}"
    end
  end
end
