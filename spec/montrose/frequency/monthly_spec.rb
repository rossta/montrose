# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency::Monthly do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "#include?" do
    it "is true when matches default monthly interval" do
      frequency = new_frequency(every: :month)

      assert frequency.include? now
      assert frequency.include? now + 2.months
      assert frequency.include? now + 30.months
    end

    it "is true when matches given monthly interval" do
      frequency = new_frequency(every: :month, interval: 5)

      assert frequency.include? now
      assert frequency.include? now + 5.months
      assert frequency.include? now + 10.months
    end

    it "is false when does not match given monthly interval" do
      frequency = new_frequency(every: :month, interval: 5)

      refute frequency.include? now + 1.months
      refute frequency.include? now + 3.months
    end
  end

  describe "#to_cron" do
    let(:now) { Time.new(2018, 5, 31, 16, 30, 0) }

    it "returns a valid crontab with no interval" do
      frequency = new_frequency(every: :month)

      assert_equal frequency.to_cron, "30 16 31 * *"
    end

    it "returns a valid crontab with an interval" do
      frequency = new_frequency(every: :month, interval: 4)

      assert_equal frequency.to_cron, "30 16 31 */4 *"
    end
  end
end
