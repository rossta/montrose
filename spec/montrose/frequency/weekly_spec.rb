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

    it "is true when matches given weekly interval with specific days" do
      start_date = Date.new(2020, 12, 2)
      frequency = new_frequency(every: :week, interval: 2, on: [:wednesday], starts: start_date)

      assert frequency.include? start_date.to_time + 2.weeks
      assert frequency.include? start_date.to_time + 4.weeks
    end

    it "is false when matches given weekly interval but not specific day" do
      start_date = Date.new(2020, 12, 2)
      frequency = new_frequency(every: :week, interval: 2, on: [:wednesday], starts: start_date)

      refute frequency.include? start_date.to_time + 2.weeks + 1.day
      refute frequency.include? start_date.to_time + 4.weeks + 1.day
    end

    it "is false when does not match given weekly interval with specific days" do
      start_date = Date.new(2020, 12, 2)
      frequency = new_frequency(every: :week, interval: 2, on: [:wednesday], starts: start_date)

      refute frequency.include? start_date.to_time + 1.weeks
      refute frequency.include? start_date.to_time + 9.weeks
    end
  end

  describe "#to_cron" do
    let(:now) { Time.new(2018, 5, 31, 16, 30, 0) }

    it "returns a valid crontab with no interval" do
      frequency = new_frequency(every: :week)

      assert_equal frequency.to_cron, "30 16 * * #{now.wday}"
    end

    it "raises on a non-weekly interval" do
      frequency = new_frequency(every: :week, interval: 2)

      assert_raises(RuntimeError) { frequency.to_cron }
    end
  end
end
