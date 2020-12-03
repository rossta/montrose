# frozen_string_literal: true

require "spec_helper"

describe Montrose::Recurrence do
  describe "examples" do
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
        Time.local(2016, 6, 28, 5, 0),
        Time.local(2016, 7, 5, 5, 0),
        Time.local(2016, 7, 12, 5, 0)
      ]
    end

    it "every 2 weeks" do
      start_date = Date.new(2019, 12, 2)
      recurrence = new_recurrence(every: :week, interval: 2, starts: start_date)

      assert recurrence.include?(start_date.to_time + 2.weeks)
      refute recurrence.include?(start_date.to_time + 1.weeks)
    end

    it "multiple at values" do
      recurrence = new_recurrence(every: :day, at: ["7:00am", "3:30pm"])

      recurrence.events.take(3).must_pair_with [
        Time.local(2015, 9, 1, 15, 30),
        Time.local(2015, 9, 2, 7, 0),
        Time.local(2015, 9, 2, 15, 30)
      ]
    end

    it "anchors to starts time outside of between range" do
      recurrence = new_recurrence(every: :day,
                                  interval: 3,
                                  starts: 1.day.ago,
                                  between: Date.today..7.days.from_now)

      recurrence.events.to_a.must_pair_with [
        Time.local(2015, 8, 31, 12),
        Time.local(2015, 9, 3,  12)
      ]
    end

    it "anchors to starts time inside of between range" do
      recurrence = new_recurrence(every: :day,
                                  interval: 3,
                                  starts: 1.day.from_now,
                                  between: Date.today..7.days.from_now)

      recurrence.events.to_a.must_pair_with [
        Time.local(2015, 9, 2, 12),
        Time.local(2015, 9, 5, 12),
        Time.local(2015, 9, 8, 12)
      ]
    end

    it "masks recurrence when starts time outside of covering range" do
      recurrence = new_recurrence(every: :day,
                                  interval: 3,
                                  starts: 1.day.ago,
                                  covering: Date.today..7.days.from_now)

      recurrence.events.to_a.must_pair_with [
        Time.local(2015, 9, 3, 12),
        Time.local(2015, 9, 6, 12)
      ]
    end

    it "masks recurrent when starts time inside of covering range" do
      recurrence = new_recurrence(every: :day,
                                  interval: 3,
                                  starts: 1.day.from_now,
                                  covering: Date.today..7.days.from_now)

      recurrence.events.to_a.must_pair_with [
        Time.local(2015, 9, 2, 12),
        Time.local(2015, 9, 5, 12),
        Time.local(2015, 9, 8, 12)
      ]
    end

    it "masks recurrence when starts time outside of between range with legacy masking" do
      Montrose.stub :enable_deprecated_between_masking?, true do
        recurrence = new_recurrence(every: :day,
                                    interval: 3,
                                    starts: 1.day.ago,
                                    between: Date.today..7.days.from_now)

        recurrence.events.to_a.must_pair_with [
          Time.local(2015, 9, 3, 12),
          Time.local(2015, 9, 6, 12)
        ]
      end
    end

    it "masks recurrence when starts time inside of between range with legacy masking" do
      Montrose.stub :enable_deprecated_between_masking?, true do
        recurrence = new_recurrence(every: :day,
                                    interval: 3,
                                    starts: 1.day.from_now,
                                    between: Date.today..7.days.from_now)

        recurrence.events.to_a.must_pair_with [
          Time.local(2015, 9, 2, 12),
          Time.local(2015, 9, 5, 12),
          Time.local(2015, 9, 8, 12)
        ]
      end
    end

    it "returns daily events with :at specified prior to :starts" do
      starts = 1.day.from_now.beginning_of_day + 12.hours
      at = "6:00am"
      recurrence = new_recurrence(every: :day, starts: starts, at: at)

      recurrence.take(3).length.must_equal 3
    end

    it "returns daily events after current time" do
      at = "6:00am"
      recurrence = new_recurrence(every: :day, at: at)

      recurrence.take(3).must_pair_with [
        Time.local(2015, 9, 2, 6),
        Time.local(2015, 9, 3, 6),
        Time.local(2015, 9, 4, 6)
      ]
    end

    # https://github.com/rossta/montrose/issues/105
    describe "yearly in month, nth day of month" do
      it "when nth day N falls in given month" do
        recurrence = new_recurrence(every: :year,
                                    month: 1,
                                    day: {friday: [2]})

        recurrence.events.take(3).to_a.must_pair_with [
          Time.local(2016, 1, 8, 12),
          Time.local(2017, 1, 13, 12),
          Time.local(2018, 1, 12, 12)
        ]
      end

      it "when nth day N falls outside of given month" do
        recurrence = new_recurrence(every: :year,
                                    month: 2,
                                    day: {friday: [2]})

        recurrence.events.take(3).to_a.must_pair_with [
          Time.local(2016, 2, 12, 12),
          Time.local(2017, 2, 10, 12),
          Time.local(2018, 2, 9, 12)
        ]
      end
    end
  end
end
