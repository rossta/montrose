require "spec_helper"

describe Montrose::Recurrence do
  let(:time_now) { Time.parse("Tuesday, September 1, 2015, 12:00 PM") }

  before do
    Timecop.freeze(time_now)
  end

  describe "self.hourly" do
    it "returns recurrence" do
      recurrence = Montrose::Recurrence.hourly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per hour by default" do
      recurrence = Montrose::Recurrence.hourly
      recurrence.events.must_have_interval 1.hour
    end
  end

  describe "self.daily" do
    it "returns recurrence" do
      recurrence = Montrose::Recurrence.daily
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per day by default" do
      recurrence = Montrose::Recurrence.daily
      recurrence.events.must_have_interval 1.day
    end
  end

  describe "self.weekly" do
    it "returns recurrence" do
      recurrence = Montrose::Recurrence.weekly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per week by default" do
      recurrence = Montrose::Recurrence.weekly
      recurrence.events.must_have_interval 1.week
    end
  end

  describe "self.monthly" do
    it "returns recurrence" do
      recurrence = Montrose::Recurrence.daily
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per week by default" do
      recurrence = Montrose::Recurrence.monthly
      recurrence.events.must_have_interval 1.month
    end
  end

  describe "self.yearly" do
    it "returns recurrence" do
      recurrence = Montrose::Recurrence.yearly
      recurrence.must_be_kind_of Montrose::Recurrence
    end

    it "emits per year by default" do
      recurrence = Montrose::Recurrence.yearly
      recurrence.events.must_have_interval((time_now + 1.year) - time_now)
    end
  end
end
