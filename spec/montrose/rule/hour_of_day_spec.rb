# frozen_string_literal: true

require "spec_helper"

describe Montrose::Rule::HourOfDay do
  let(:rule) { Montrose::Rule::HourOfDay.new([1, 10, 23]) }

  describe "#include?" do
    it { refute rule.include?(Time.parse("12:00 AM")) }
    it { assert rule.include?(Time.parse("1:00 AM")) }
    it { refute rule.include?(Time.parse("2:00 AM")) }
    it { assert rule.include?(Time.parse("10:00 AM")) }
    it { refute rule.include?(Time.parse("11:00 AM")) }
    it { assert rule.include?(Time.parse("11:00 PM")) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
