# frozen_string_literal: true

require "spec_helper"

describe Montrose::Clock do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#tick" do
    it "must start with given starts time" do
      clock = new_clock(every: :minute, starts: now)
      _(clock.tick).must_equal now
    end

    it "emits 1 minute increments" do
      clock = new_clock(every: :minute)

      _(clock).must_have_tick 1.minute
    end

    it "emits minute interval increments" do
      clock = new_clock(every: :minute, interval: 30)

      _(clock).must_have_tick 30.minutes
    end

    it "emits 1 hour increments" do
      clock = new_clock(every: :hour)

      _(clock).must_have_tick 1.hour
    end

    it "emits 1 hour increments when hour smallest part" do
      clock = new_clock(every: :day, hour: 9..10)

      _(clock).must_have_tick 1.hour
    end

    it "emits hour interval increments" do
      clock = new_clock(every: :hour, interval: 6)

      _(clock).must_have_tick 6.hours
    end

    it "emits 1 day increments for :day" do
      clock = new_clock(every: :day)

      _(clock).must_have_tick 1.day
    end

    it "emits 1 day increments for :mday" do
      clock = new_clock(every: :month, mday: [1, -1])

      _(clock).must_have_tick 1.day
    end

    it "emits 1 day increments for :yday" do
      clock = new_clock(every: :year, yday: [1, 10, 100])

      _(clock).must_have_tick 1.day
    end

    it "emits day interval increments" do
      clock = new_clock(every: :day, interval: 3)

      _(clock).must_have_tick 3.days
    end

    it "emits 1 day increments when day smallest part" do
      clock = new_clock(every: :month, day: :tuesday)

      _(clock).must_have_tick 1.day
    end

    it "emits 1 week increments" do
      clock = new_clock(every: :week)

      _(clock).must_have_tick 1.week
    end

    it "emits week interval increments" do
      clock = new_clock(every: :week, interval: 2)

      _(clock).must_have_tick 2.weeks
    end

    it "emits 1 year increments" do
      clock = new_clock(every: :year)

      _(clock).must_have_tick 1.year
    end

    it "emits year interval increments" do
      clock = new_clock(every: :year, interval: 10)

      _(clock).must_have_tick 10.years
    end

    it "emits increments on at values" do
      Timecop.freeze(Time.local(2018, 5, 31, 11)) do
        clock = new_clock(every: :day, at: [[10, 0, 59], [15, 30, 34]])

        _(clock.tick).must_equal Time.local(2018, 5, 31, 15, 30, 34)
        _(clock.tick).must_equal Time.local(2018, 6, 1, 10, 0, 59)
        _(clock.tick).must_equal Time.local(2018, 6, 1, 15, 30, 34)
      end
    end

    it "emits correct tick when at values empty" do
      clock = new_clock(every: :day, at: [])

      _(clock).must_have_tick 1.day
    end
  end

  describe "#peek" do
    it "does not cause clock to tick" do
      Timecop.freeze(Time.local(2018, 5, 31, 11)) do
        clock = new_clock(every: :day, at: [[10, 0, 59], [15, 30, 34]])

        _(clock.peek).must_equal Time.local(2018, 5, 31, 15, 30, 34)
        _(clock.peek).must_equal Time.local(2018, 5, 31, 15, 30, 34)
        _(clock.tick).must_equal Time.local(2018, 5, 31, 15, 30, 34)
        _(clock.peek).must_equal Time.local(2018, 6, 1, 10, 0, 59)
        _(clock.peek).must_equal Time.local(2018, 6, 1, 10, 0, 59)
        _(clock.tick).must_equal Time.local(2018, 6, 1, 10, 0, 59)
        _(clock.peek).must_equal Time.local(2018, 6, 1, 15, 30, 34)
        _(clock.peek).must_equal Time.local(2018, 6, 1, 15, 30, 34)
        _(clock.tick).must_equal Time.local(2018, 6, 1, 15, 30, 34)
        _(clock.peek).must_equal Time.local(2018, 6, 2, 10, 0, 59)
        _(clock.tick).must_equal Time.local(2018, 6, 2, 10, 0, 59)
        _(clock.peek).must_equal Time.local(2018, 6, 2, 15, 30, 34)
        _(clock.tick).must_equal Time.local(2018, 6, 2, 15, 30, 34)
      end
    end
  end
end
