# frozen_string_literal: true

require "spec_helper"

describe Montrose::Schedule do
  let(:schedule) { new_schedule }

  describe ".build" do
    it "returns a new instance" do
      Montrose::Schedule.build.must_be_kind_of Montrose::Schedule
    end

    it "yields a new instance" do
      schedule = Montrose::Schedule.build { |s|
        s << {every: :day}
        s << {every: :year}
      }

      schedule.rules.size.must_equal 2
    end
  end

  describe ".dump" do
    it "returns options as JSON string" do
      schedule = new_schedule([
        {every: :week, on: :thursday, at: "7pm"},
        {every: :week, on: :tuesday, at: "6pm"}
      ])

      dump = Montrose::Schedule.dump(schedule)
      parsed = JSON.parse(dump).map(&:symbolize_keys)
      parsed[0][:every].must_equal "week"
      parsed[0][:on].must_equal "thursday"
      parsed[0][:at].must_equal [[19, 0, 0]]
      parsed[1][:every].must_equal "week"
      parsed[1][:on].must_equal "tuesday"
      parsed[1][:at].must_equal [[18, 0, 0]]
    end

    it "accepts json array" do
      array = [
        {every: :week, on: :thursday, at: "7pm"},
        {every: :week, on: :tuesday, at: "6pm"}
      ]

      dump = Montrose::Schedule.dump(array)
      parsed = JSON.parse(dump).map(&:symbolize_keys)
      parsed[0][:every].must_equal "week"
      parsed[0][:on].must_equal "thursday"
      parsed[0][:at].must_equal [[19, 0, 0]]
      parsed[1][:every].must_equal "week"
      parsed[1][:on].must_equal "tuesday"
      parsed[1][:at].must_equal [[18, 0, 0]]
    end

    it "accepts json string" do
      str = [
        {every: :week, on: :thursday, at: "7pm"},
        {every: :week, on: :tuesday, at: "6pm"}
      ].to_json

      dump = Montrose::Schedule.dump(str)
      parsed = JSON.parse(dump).map(&:symbolize_keys)
      parsed[0][:every].must_equal "week"
      parsed[0][:on].must_equal "thursday"
      parsed[0][:at].must_equal [[19, 0, 0]]
      parsed[1][:every].must_equal "week"
      parsed[1][:on].must_equal "tuesday"
      parsed[1][:at].must_equal [[18, 0, 0]]
    end

    it { Montrose::Schedule.dump(nil).must_be_nil }

    it "raises error if str not parseable as JSON" do
      -> { Montrose::Schedule.dump("foo") }.must_raise Montrose::SerializationError
    end

    it "raises error otherwise" do
      -> { Montrose::Schedule.dump(Object.new) }.must_raise Montrose::SerializationError
    end
  end

  describe ".load" do
    it "returns Recurrence instance" do
      schedule = new_schedule([
        {every: :week, on: :thursday, at: "7pm"},
        {every: :week, on: :tuesday, at: "6pm"}
      ])

      dump = Montrose::Schedule.dump(schedule)
      loaded = Montrose::Schedule.load(dump).to_a

      loaded[0][:every].must_equal :week
      loaded[0][:on].must_equal "thursday"
      loaded[0][:at].must_equal [[19, 0, 0]]
      loaded[1][:every].must_equal :week
      loaded[1][:on].must_equal "tuesday"
      loaded[1][:at].must_equal [[18, 0, 0]]
    end

    it "returns nil for nil dump" do
      loaded = Montrose::Schedule.load(nil)

      loaded.must_be_nil
    end

    it "returns nil for empty dump" do
      loaded = Montrose::Schedule.load("")

      loaded.must_be_nil
    end
  end

  describe "#add" do
    it "adds options as new recurrence rule" do
      options = {every: :year, total: 3}
      schedule.add(options)

      schedule.rules.size.must_equal 1

      rule = schedule.rules.first
      rule.default_options[:every].must_equal :year
      rule.default_options[:total].must_equal 3
    end

    it "accepts a recurrence rule" do
      schedule.add(Montrose.yearly.total(3))

      schedule.rules.size.must_equal 1

      rule = schedule.rules.first
      rule.default_options[:every].must_equal :year
      rule.default_options[:total].must_equal 3
    end

    it "is aliased to #<<" do
      options = {every: :year, total: 3}
      schedule << options

      schedule.rules.size.must_equal 1

      rule = schedule.rules.first
      rule.default_options[:every].must_equal :year
      rule.default_options[:total].must_equal 3
    end
  end

  describe "#events" do
    it "combines events of given rules in order" do
      today = Date.today.to_time

      schedule.add(every: 2.days, total: 2, starts: today)
      schedule.add(every: 2.days, total: 2, starts: today + 1.day)

      events = schedule.events.to_a
      events.must_pair_with [
        today,
        today + 1.day,
        today + 2.days,
        today + 3.days
      ]
      events.size.must_equal 4
    end

    it "is an enumerator" do
      schedule.events.must_be_instance_of(Enumerator)
    end
  end

  describe "#each" do
    it "is defined" do
      schedule.must_respond_to :each
    end

    it "responsds to enumerable methods" do
      today = Date.today.to_time

      schedule.add(every: 2.days, total: 2, starts: today)
      schedule.add(every: 2.days, total: 2, starts: today + 1.day)

      events = schedule.take(4).to_a
      events.must_pair_with [
        today,
        today + 1.day,
        today + 2.days,
        today + 3.days
      ]
      events.size.must_equal 4
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

  describe "#inspect" do
    before do
      schedule << {every: :month}
      schedule << {every: :day}
    end

    it "is readable" do
      inspected = "#<Montrose::Schedule:#{schedule.object_id.to_s(16)} " \
                  "[{:every=>:month}, {:every=>:day}]>"
      schedule.inspect.must_equal inspected
    end
  end

  describe "#to_json" do
    before do
      schedule << {every: :month}
      schedule << {every: :day}
    end

    it "returns json string of its options" do
      schedule.to_json.must_equal "[{\"every\":\"month\"},{\"every\":\"day\"}]"
    end
  end

  describe "#to_a" do
    before do
      schedule << {every: :month}
      schedule << {every: :day}
    end

    it "returns default options as array" do
      array = schedule.to_a

      array.size.must_equal 2
      array.must_equal [{every: :month}, {every: :day}]
    end
  end

  describe "#as_json" do
    before do
      schedule << {every: :month}
      schedule << {every: :day}
    end

    it "returns default options as array" do
      array = schedule.as_json

      array.size.must_equal 2
      array.must_equal [{"every" => "month"}, {"every" => "day"}]
    end
  end

  describe "#to_yaml" do
    before do
      schedule << {every: :month}
      schedule << {every: :day}
    end

    it "returns default options as array" do
      yaml = schedule.to_yaml

      array = YAML.safe_load(yaml)
      array.size.must_equal 2
      array.must_equal [{"every" => "month"}, {"every" => "day"}]
    end
  end
end
