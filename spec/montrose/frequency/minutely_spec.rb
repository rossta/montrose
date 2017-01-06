# frozen_string_literal: true
require "spec_helper"

describe Montrose::Frequency::Minutely do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default minutely interval" do
      frequency = new_frequency(every: :minute)

      assert frequency.include? now
      assert frequency.include? now + 2.minutes
      assert frequency.include? now + 30.minutes
    end

    it "is true when matches given minutely interval" do
      frequency = new_frequency(every: :minute, interval: 30)

      assert frequency.include? now
      assert frequency.include? now + 30.minutes
      assert frequency.include? now + 1.hour
    end

    it "is false when does not match default minutely interval" do
      frequency = new_frequency(every: :minute)

      refute frequency.include? now + 1.second
      refute frequency.include? now + 2.minutes + 2.seconds
      refute frequency.include? now + 30.minutes + 3.seconds
    end

    it "is false when does not match given minutely interval" do
      frequency = new_frequency(every: :minute, interval: 30)

      refute frequency.include? now + 1.minutes
      refute frequency.include? now + 30.minutes + 2.minutes
      refute frequency.include? now + 60.minutes + 3.minutes
    end
  end
end
