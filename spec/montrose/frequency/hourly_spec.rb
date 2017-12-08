# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency::Hourly do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default hourly interval" do
      frequency = new_frequency(every: :hour)

      assert frequency.include? now
      assert frequency.include? now + 2.hours
      assert frequency.include? now + 30.hours
    end

    it "is true when matches given hourly interval" do
      frequency = new_frequency(every: :hour, interval: 5)

      assert frequency.include? now
      assert frequency.include? now + 5.hours
      assert frequency.include? now + 10.hours
    end

    it "is false when does not match default hourly interval" do
      frequency = new_frequency(every: :hour)

      refute frequency.include? now + 1.second
      refute frequency.include? now + 2.hours + 2.seconds
      refute frequency.include? now + 30.hours + 3.minutes
    end

    it "is false when does not match given hourly interval" do
      frequency = new_frequency(every: :hour, interval: 5)

      refute frequency.include? now + 1.hours
      refute frequency.include? now + 3.hours
      refute frequency.include? now + 10.hours + 3.minutes
    end
  end
end
