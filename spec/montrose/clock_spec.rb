require "spec_helper"

describe Montrose::Clock do
  let(:time_now) { Time.now }

  before do
    Timecop.freeze(time_now)
  end

  describe "#tick" do
    it "must start with given starts time" do
      clock = new_clock(starts: time_now)
      clock.tick.must_equal time_now
    end

    it "emits 1 minute increments" do
      clock = new_clock(every: :minute)

      clock.must_have_tick 1.minute
    end

    it "emits 1 minute increments when smallest part is minute" do
      clock = new_clock(every: :hour, minute: 20)

      clock.must_have_tick 1.minute
    end

    it "emits minute interval increments" do
      clock = new_clock(every: :minute, interval: 30)

      clock.must_have_tick 30.minutes
    end

    it "emits 1 hour increments" do
      clock = new_clock(every: :hour)

      clock.must_have_tick 1.hour
    end

    it "emits 1 hour increments when hour smallest part" do
      clock = new_clock(every: :day, hour: 9..10)

      clock.must_have_tick 1.hour
    end

    it "emits hour interval increments" do
      clock = new_clock(every: :hour, interval: 6)

      clock.must_have_tick 6.hours
    end

    it "emits 1 day increments for :day" do
      clock = new_clock(every: :day)

      clock.must_have_tick 1.day
    end

    it "emits 1 day increments for :mday"
    it "emits 1 day increments for :yday"
    it "emits day interval increments"
    it "emits 1 week increments"
    it "emits week interval increments"
    it "emits 1 year increments"
    it "emits year interval increments"
  end
end
