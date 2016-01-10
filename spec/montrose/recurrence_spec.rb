require "spec_helper"

describe Montrose::Recurrence do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
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

      times.must_pair_with([now, 1.hour.from_now, 2.hours.from_now])
      times.size.must_equal 3
    end

    it "accepts options to modify defaults" do
      recurrence = new_recurrence(every: :hour, total: 1)

      times = []
      recurrence.each(every: :week, total: 3) do |time|
        times << time
      end

      times.must_pair_with([now, 1.week.from_now, 2.weeks.from_now])
      times.size.must_equal 3
    end

    it "is enumerable" do
      recurrence = new_recurrence(every: :day, total: 3)

      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
    end
  end

  describe "#starts" do
    it "returns given starts time" do
      new_recurrence(every: :minute).starts.must_equal now
      new_recurrence(every: :hour, starts: 1.hour.from_now).starts.must_equal 1.hour.from_now
    end

    it "returns logical starts time" do
      noon_today = now.beginning_of_day + 12.hours
      Timecop.freeze(noon_today)

      recurrence_today = new_recurrence(every: :day, at: "3:00 PM")
      recurrence_today.starts.must_equal noon_today + 3.hours

      recurrence_tomorrow = new_recurrence(every: :day, at: "11:00 AM")
      recurrence_tomorrow.starts.must_equal Date.tomorrow + 11.hours
    end
  end

  describe "additional recurrence examples" do
    let(:now) { Time.local(2015, 9, 1, 12) } # Tuesday

    before do
      Timecop.freeze(now)
    end

    it "every day at 3:30pm" do
      recurrence = new_recurrence(every: :day, at: "3:30 PM")

      recurrence.events.take(3).must_pair_with [
        Time.local(2015, 9, 1, 15, 30),
        Time.local(2015, 9, 2, 15, 30),
        Time.local(2015, 9, 3, 15, 30)
      ]
    end
  end
end
