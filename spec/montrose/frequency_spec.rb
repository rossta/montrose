# frozen_string_literal: true

require "spec_helper"

describe Montrose::Frequency do
  let(:now) { time_now }

  before do
    Timecop.freeze(now)
  end

  describe "self.from_options" do
    it "every: :year" do
      frequency = Montrose::Frequency.from_options(every: :year)
      _(frequency).must_be_instance_of Montrose::Frequency::Yearly
    end

    it "every: :week" do
      frequency = Montrose::Frequency.from_options(every: :week)
      _(frequency).must_be_instance_of Montrose::Frequency::Weekly
    end

    it "every: :month" do
      frequency = Montrose::Frequency.from_options(every: :month)
      _(frequency).must_be_instance_of Montrose::Frequency::Monthly
    end

    it "every: :day" do
      frequency = Montrose::Frequency.from_options(every: :day)
      _(frequency).must_be_instance_of Montrose::Frequency::Daily
    end

    it "every: :hour" do
      frequency = Montrose::Frequency.from_options(every: :hour)
      _(frequency).must_be_instance_of Montrose::Frequency::Hourly
    end

    it "every: :minute" do
      frequency = Montrose::Frequency.from_options(every: :minute)
      _(frequency).must_be_instance_of Montrose::Frequency::Minutely
    end

    it "every: 'minute' as string value" do
      frequency = Montrose::Frequency.from_options(every: "minute")
      _(frequency).must_be_instance_of Montrose::Frequency::Minutely
    end

    it "every: :other" do
      _(-> { Montrose::Frequency.from_options(every: :other) }).must_raise
    end

    it "missing every" do
      _(-> { Montrose::Frequency.from_options({}) }).must_raise
    end
  end
end
