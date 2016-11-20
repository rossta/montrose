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

    it "is mappable" do
      recurrence = new_recurrence(every: :day, total: 3)

      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
    end

    it "enumerates anew each time" do
      recurrence = new_recurrence(every: :day, total: 3)

      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
      recurrence.map(&:to_date).must_equal [Date.today, Date.tomorrow, 2.days.from_now.to_date]
    end

    it "returns first" do
      recurrence = new_recurrence(every: :day)

      recurrence.first.must_equal now
    end

    it "returns enumerator" do
      recurrence = new_recurrence(every: :day)

      recurrence.each.must_be_kind_of Enumerator
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
      default_options[:starts].to_i.must_equal now.to_i
      default_options[:interval].must_equal 1
    end
  end

  describe "integration specs" do
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

    it "specifying starts and at option" do
      recurrence = new_recurrence(every: :week, on: "tuesday", at: "5:00", starts: "2016-06-23")

      recurrence.events.take(3).must_pair_with [
        Time.local(2016, 6, 28, 5, 0o0),
        Time.local(2016, 7, 5,  5, 0o0),
        Time.local(2016, 7, 12, 5, 0o0)
      ]
    end

    it "multiple at values" do
      recurrence = new_recurrence(every: :day, at: ["7:00am", "3:30pm"])

      recurrence.events.take(3).must_pair_with [
        Time.local(2015, 9, 1, 7,  0o0),
        Time.local(2015, 9, 1, 15, 30),
        Time.local(2015, 9, 2, 7,  0o0)
      ]
    end
  end

  describe "#inspect" do
    let(:now) { time_now }
    let(:recurrence) { new_recurrence(every: :month, starts: now, interval: 1) }

    it "is readable" do
      inspected = "#<Montrose::Recurrence:#{recurrence.object_id.to_s(16)} "
      inspected << "{:every=>:month, :starts=>#{now.inspect}, :interval=>1}>"
      recurrence.inspect.must_equal inspected
    end
  end

  describe "#to_json" do
    it "returns json string of its options" do
      options = { every: :day, at: "3:45pm" }
      recurrence = new_recurrence(options)

      recurrence.to_json.must_equal "{\"every\":\"day\",\"at\":[[15,45]]}"
    end
  end

  describe "#include?" do
    let(:now) { Time.local(2015, 9, 1, 12) } # Tuesday

    before do
      Timecop.freeze(now)
    end

    it "is true when given timestamp intersects infinite recurrence" do
      recurrence = new_recurrence(every: :day, at: "3:30 PM")

      timestamp = 3.days.from_now.beginning_of_day.advance(hours: 15, minutes: 30)
      recurrence.include?(timestamp)
    end

    it "is false when given timestamp not included in recurrence" do
      recurrence = new_recurrence(every: :week, on: "tuesday", at: "5:00", starts: "2016-06-23")

      timestamp = 3.days.from_now.beginning_of_day.advance(hours: 15, minutes: 31)

      recurrence.include?(timestamp).must_equal false
    end

    it "is false if falls outside range" do
      recurrence = new_recurrence(every: :day, at: "3:30 PM").repeat(3)

      timestamp = 4.days.from_now.beginning_of_day.advance(hours: 15, minutes: 30)
      recurrence.include?(timestamp).must_equal false
    end
  end
end
