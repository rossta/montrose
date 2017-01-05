# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::DayOfWeek do
  let(:rule) { Montrose::Rule::DayOfWeek.new([0, 2, 6]) }

  describe "#include?" do
    it { refute rule.include?(Time.local(2016, 1, 1)) }
    it { assert rule.include?(Time.local(2016, 1, 2)) }
    it { assert rule.include?(Time.local(2016, 1, 3)) }
    it { refute rule.include?(Time.local(2016, 1, 4)) }
    it { assert rule.include?(Time.local(2016, 1, 5)) }
    it { refute rule.include?(Time.local(2016, 1, 6)) }
    it { refute rule.include?(Time.local(2015, 1, 7)) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
