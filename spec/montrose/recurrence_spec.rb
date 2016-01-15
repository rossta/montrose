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

    it "is enumerable" do
      recurrence = new_recurrence(every: :day, total: 3)

      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
    end
  end

  describe "#to_hash" do
    it "returns default options as hash" do
      now = time_now
      options = { every: :day, total: 3, starts: now, interval: 1 }
      recurrence = new_recurrence(options)
      recurrence.to_hash.must_equal options
    end
  end

  describe ".dump" do
    it "returns options as JSON string" do
      now = time_now
      options = { every: :day, total: 3, starts: now, interval: 1 }
      recurrence = new_recurrence(options)

      dump = Montrose::Recurrence.dump(recurrence)
      parsed = JSON.parse(dump).symbolize_keys
      parsed[:every].must_equal "day"
      parsed[:total].must_equal 3
      parsed[:interval].must_equal 1
      parsed[:starts].must_equal now.to_s
    end

    it "raises error if not a self" do
      -> { Montrose::Recurrence.dump(Object.new) }.must_raise Montrose::SerializationError
    end

    it { Montrose::Recurrence.dump(nil).must_be_nil }
  end

  describe ".load" do
    it "returns Recurrence instance" do
      now = time_now
      options = { every: :day, total: 3, starts: now, interval: 1 }
      recurrence = new_recurrence(options)
      dump = Montrose::Recurrence.dump(recurrence)

      loaded = Montrose::Recurrence.load(dump)

      default_options = loaded.default_options
      default_options[:every].must_equal :day
      default_options[:total].must_equal 3
      default_options[:starts].must_equal now
      default_options[:interval].must_equal 1
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
