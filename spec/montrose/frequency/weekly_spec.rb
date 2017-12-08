# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency::Weekly do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default weekly interval" do
      frequency = new_frequency(every: :week)

      assert frequency.include? now
      assert frequency.include? now + 2.weeks
      assert frequency.include? now + 30.weeks
    end

    it "is true when matches given weekly interval" do
      frequency = new_frequency(every: :week, interval: 5)

      assert frequency.include? now
      assert frequency.include? now + 5.weeks
      assert frequency.include? now + 10.weeks
    end

    it "is false when does not match given weekly interval" do
      frequency = new_frequency(every: :week, interval: 5)

      refute frequency.include? now + 1.weeks
      refute frequency.include? now + 3.weeks
    end
  end
end
