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
        Time.local(2016, 7, 5,  5, 0),
        Time.local(2016, 7, 12, 5, 0)
      ]
    end

    it "multiple at values" do
      recurrence = new_recurrence(every: :day, at: ["7:00am", "3:30pm"])

      recurrence.events.take(3).must_pair_with [
        Time.local(2015, 9, 1, 7,  0),
        Time.local(2015, 9, 1, 15, 30),
        Time.local(2015, 9, 2, 7,  0)
      ]
    end

    it "anchors to starts time outside of between range" do
      recurrence = new_recurrence(every: :day,
                                  interval: 3,
                                  starts: 1.day.ago,
                                  between: Date.today..7.days.from_now)

      recurrence.events.to_a.must_pair_with [
        Time.local(2015, 9, 3, 12),
        Time.local(2015, 9, 6, 12)
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
  end
end
