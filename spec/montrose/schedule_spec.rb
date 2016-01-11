require "spec_helper"

describe Montrose::Schedule do
  let(:schedule) { new_schedule }

  describe "#add" do
    it "adds options as new recurrence rule" do
      options = { every: :year, total: 3 }
      schedule.add(options)

      schedule.rules.size.must_equal 1

      rule = schedule.rules.first
      rule.default_options[:every].must_equal :year
      rule.default_options[:total].must_equal 3
    end
  end

  describe "#events" do
    it "combines events of given rules in order" do
      today = Date.today.to_time

      skip("Schedule does not support multiple recurrence rules yet")

      schedule.add(every: :day, total: 2, starts: today)
      schedule.add(every: :day, total: 2, starts: today + 1.day)

      events = schedule.events
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
