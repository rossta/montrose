# frozen_string_literal: true

require "spec_helper"
require "benchmark"

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
      options = {every: :day, total: 3, starts: now, interval: 1}
      recurrence = new_recurrence(options)
      hash = recurrence.to_hash

      hash.size.must_equal 4
      hash[:every].must_equal :day
      hash[:interval].must_equal 1
      hash[:total].must_equal 3
      hash[:starts].must_equal now
    end
  end

  describe "#as_json" do
    it "returns default options as json" do
      options = {every: :day, total: 3, starts: now, interval: 1}
      recurrence = new_recurrence(options)
      hash = recurrence.as_json

      hash.size.must_equal 4
      hash["every"].must_equal "day"
      hash["interval"].must_equal 1
      hash["total"].must_equal 3
      hash["starts"].must_equal now.as_json
    end
  end

  describe "#to_yaml" do
    it "returns default options as yaml" do
      options = {every: :day, starts: now, interval: 1, total: 3}
      recurrence = new_recurrence(options)

      yaml = recurrence.to_yaml
      recurrence_from_yaml = new_recurrence(YAML.safe_load(yaml))

      hash = recurrence_from_yaml.to_hash
      hash[:every].must_equal :day
      hash[:interval].must_equal 1
      hash[:total].must_equal 3
      hash[:starts].must_equal now
    end
  end

  describe ".dump" do
    it "returns options as JSON string" do
      options = {every: :day, total: 3, starts: now, interval: 1}
      recurrence = new_recurrence(options)

      dump = Montrose::Recurrence.dump(recurrence)
      parsed = JSON.parse(dump).symbolize_keys
      parsed[:every].must_equal "day"
      parsed[:total].must_equal 3
      parsed[:interval].must_equal 1
      parsed[:starts].must_equal now.to_s
    end

    it "accepts json hash" do
      hash = {every: :day, total: 3, starts: now, interval: 1}

      dump = Montrose::Recurrence.dump(hash)
      parsed = JSON.parse(dump).symbolize_keys
      parsed[:every].must_equal "day"
      parsed[:total].must_equal 3
      parsed[:interval].must_equal 1
      parsed[:starts].must_equal now.to_s
    end

    it "accepts json string" do
      str = {every: :day, total: 3, starts: now, interval: 1}.to_json

      dump = Montrose::Recurrence.dump(str)
      parsed = JSON.parse(dump).symbolize_keys

      parsed[:every].must_equal "day"
      parsed[:total].must_equal 3
      parsed[:interval].must_equal 1
      parsed[:starts].must_equal now.to_s
    end

    it { Montrose::Recurrence.dump(nil).must_be_nil }

    it "raises error if str not parseable as JSON" do
      -> { Montrose::Recurrence.dump("foo") }.must_raise Montrose::SerializationError
    end

    it "raises error otherwise" do
      -> { Montrose::Recurrence.dump(Object.new) }.must_raise Montrose::SerializationError
    end
  end

  describe ".load" do
    it "returns Recurrence instance" do
      options = {every: :day, total: 3, starts: now, interval: 1}
      recurrence = new_recurrence(options)
      dump = Montrose::Recurrence.dump(recurrence)

      loaded = Montrose::Recurrence.load(dump)

      default_options = loaded.default_options
      default_options[:every].must_equal :day
      default_options[:total].must_equal 3
      default_options[:starts].to_i.must_equal now.to_i
      default_options[:interval].must_equal 1
    end

    it "returns nil for nil dump" do
      loaded = Montrose::Recurrence.load(nil)

      loaded.must_be_nil
    end

    it "returns nil for empty dump" do
      loaded = Montrose::Recurrence.load("")

      loaded.must_be_nil
    end
  end

  describe "#inspect" do
    let(:now) { time_now }
    let(:recurrence) { new_recurrence(every: :month, starts: now, interval: 1) }

    it "is readable" do
      inspected = "#<Montrose::Recurrence:#{recurrence.object_id.to_s(16)} " \
                  "{:every=>:month, :starts=>#{now.inspect}, :interval=>1}>"
      recurrence.inspect.must_equal inspected
    end
  end

  describe "#to_json" do
    it "returns json string of its options" do
      options = {every: :day, at: "3:45pm"}
      recurrence = new_recurrence(options)

      recurrence.to_json.must_equal "{\"every\":\"day\",\"at\":[[15,45,0]]}"
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

      assert recurrence.include?(timestamp)
    end

    it "is false when given timestamp not included in recurrence" do
      recurrence = new_recurrence(every: :week).on("tuesday").at("5:00").starts("2016-06-23")

      timestamp = 3.days.from_now.beginning_of_day.advance(hours: 15, minutes: 31)

      refute recurrence.include?(timestamp)
    end

    it "is false if falls outside finite range by total" do
      recurrence = new_recurrence(every: :day).at("3:30 PM").repeat(3)

      timestamp = 4.days.from_now.beginning_of_day.advance(hours: 15, minutes: 30)

      refute recurrence.include?(timestamp)
    end

    it "is false if falls after finite range by date" do
      recurrence = new_recurrence(every: :day).at("3:30 PM").ending(10.days.from_now)

      timestamp = 11.days.from_now.beginning_of_day.advance(hours: 15, minutes: 30)

      refute recurrence.include?(timestamp)
    end

    it "is false if falls before finite range by date" do
      recurrence = new_recurrence(every: :day).at("3:30 PM").starts(1.day.from_now)

      timestamp = Time.now.beginning_of_day.advance(hours: 15, minutes: 30)

      refute recurrence.include?(timestamp)
    end

    it "is optimized to handle long/infinite recurrences" do
      recurrence = new_recurrence(every: :day).at("3:30 PM")
      far_future_timestamp = 100_000.days.from_now.beginning_of_day
      far_future_timestamp = far_future_timestamp.advance(hours: 15, minutes: 30)

      elapsed = Benchmark.realtime {
        assert recurrence.include?(far_future_timestamp)
      }

      assert_operator 1.0, :>, elapsed.to_f,
        "Elased time was too long: %.1f seconds" % elapsed
    end
  end

  describe "#finite? / #infinite?" do
    it "is true if there is an ends at" do
      recurrence = new_recurrence(every: :day).ending(1.day.from_now)
      assert_equal recurrence.finite?, true
      assert_equal recurrence.infinite?, false
    end

    it "is true if there is a length" do
      recurrence = new_recurrence(every: :day).repeat(3)
      assert_equal recurrence.finite?, true
      assert_equal recurrence.infinite?, false
    end

    it "is false if there is no end date or length" do
      recurrence = new_recurrence(every: :day)
      assert_equal recurrence.finite?, false
      assert_equal recurrence.infinite?, true
    end
  end

  describe "intervals" do
    before do
      Timecop.return # turn off timecop to test enumeration against real clock
    end

    # Test for issue #101 in which interval comparisons for
    # second, minute, and hour were failing, cause enumeration
    # to get stuck in an infinite loop.
    require "timeout"
    [:second, :minute, :hour, :day, :month, :year].each do |interval|
      it "returns enumerable for every recognized interval" do
        recurrence = new_recurrence(every: interval)
        begin
          Timeout.timeout(2) do
            recurrence.take(5).length.must_equal 5
          end
        rescue Timeout::Error
          assert false, "Expected recurrence for every #{interval.inspect} to return 5 results but timed out."
        end
      end
    end
  end
end
