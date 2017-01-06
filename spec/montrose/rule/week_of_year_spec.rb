# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::WeekOfYear do
  let(:rule) { Montrose::Rule::WeekOfYear.new([1, 20, 53]) }

  describe "#include?" do
    it { assert rule.include?(Time.local(2015, 12, 31)) }
    it { assert rule.include?(Time.local(2016, 1, 4)) }
    it { refute rule.include?(Time.local(2016, 2, 2)) }
    it { refute rule.include?(Time.local(2016, 5, 4)) }
    it { assert rule.include?(Time.local(2016, 5, 17)) }
    it { refute rule.include?(Time.local(2016, 11, 30)) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
