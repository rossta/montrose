require "spec_helper"

describe Montrose::Recurrence do
  before do
    Timecop.freeze(Time.now)
  end

  describe "#events" do
    it "returns Enumerator" do
      recurrence = new_recurrence(every: :hour)
      recurrence.events.must_be_instance_of Enumerator
    end
  end

  describe "#each" do
    it "iterates events" do
      recurrence = new_recurrence(every: :hour, total: 3)

      times = []
      recurrence.each do |time|
        times << time
      end

      times.must_pair_with([Time.now, 1.hour.from_now, 2.hours.from_now])
      times.size.must_equal 3
    end

    it "accepts options to modify defaults" do
      recurrence = new_recurrence(every: :hour, total: 1)

      times = []
      recurrence.each(every: :week, total: 3) do |time|
        times << time
      end

      times.must_pair_with([Time.now, 1.week.from_now, 2.weeks.from_now])
      times.size.must_equal 3
    end

    it "is enumerable" do
      recurrence = new_recurrence(every: :day, total: 3)

      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
    end
  end

  describe "#starts" do
    it "returns starting time" do
      new_recurrence.starts.must_equal Time.now
      new_recurrence(starts: 1.hour.from_now).starts.must_equal 1.hour.from_now
    end
  end
end
