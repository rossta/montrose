# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency::Daily do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default daily interval" do
      frequency = new_frequency(every: :day)

      assert frequency.include? now
      assert frequency.include? now + 2.days
      assert frequency.include? now + 30.days
    end

    it "is true when matches given daily interval" do
      frequency = new_frequency(every: :day, interval: 5)

      assert frequency.include? now
      assert frequency.include? now + 5.days
      assert frequency.include? now + 10.days
    end

    it "is false when does not match given daily interval" do
      frequency = new_frequency(every: :day, interval: 5)

      refute frequency.include? now + 1.days
      refute frequency.include? now + 3.days
    end
  end

  describe "#to_cron" do
    let(:now) { Time.new(2018, 5, 31, 16, 30, 0) }

    it "returns a valid crontab entry with no interval" do
      frequency = new_frequency(every: :day)

      assert_equal frequency.to_cron, "30 16 * * *"
    end

    it "returns a valid crontab entry with days interval" do
      frequency = new_frequency(every: :day, interval: 2)

      assert_equal frequency.to_cron, "30 16 */2 * *"
    end
  end
end
