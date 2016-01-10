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

    it "emits given frequencey by default" do
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
  end

  describe "#day_of_year" do
    it "returns new recurrence by given days of month" do
      recurrence = Montrose.yearly
      recurrence = recurrence.day_of_year(1, 10, 100)

      recurrence.events.must_pair_with [
        Time.local(2016, 1, 1, 12),
        Time.local(2016, 1, 10, 12),
        Time.local(2016, 4, 9, 12) # 100th day
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
  end
end
