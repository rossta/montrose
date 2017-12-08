# frozen_string_literal: true

require "spec_helper"

describe Montrose::Schedule do
  let(:schedule) { new_schedule }

  describe ".build" do
    it "returns a new instance" do
      Montrose::Schedule.build.must_be_kind_of Montrose::Schedule
    end

    it "yields a new instance" do
      schedule = Montrose::Schedule.build do |s|
        s << { every: :day }
        s << { every: :year }
      end

      schedule.rules.size.must_equal 2
    end
  end

  describe "#add" do
    it "adds options as new recurrence rule" do
      options = { every: :year, total: 3 }
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
      options = { every: :year, total: 3 }
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
  end
end
