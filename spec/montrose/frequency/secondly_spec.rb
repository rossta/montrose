# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency::Secondly do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default secondly interval" do
      frequency = new_frequency(every: :second)

      assert frequency.include? now
      assert frequency.include? now + 2.seconds
      assert frequency.include? now + 30.seconds
    end

    it "is true when matches given secondly interval" do
      frequency = new_frequency(every: :second, interval: 5)

      assert frequency.include? now
      assert frequency.include? now + 5.seconds
      assert frequency.include? now + 10.seconds
    end

    it "is false when does not match given secondly interval" do
      frequency = new_frequency(every: :second, interval: 5)

      refute frequency.include? now + 1.second
      refute frequency.include? now + 3.seconds
    end
  end
end
