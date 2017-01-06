# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::DayOfYear do
  let(:rule) { Montrose::Rule::DayOfYear.new([1, 100, -1]) }

  describe "#include?" do
    it { assert rule.include?(Time.local(2015, 1, 1)) }
    it { assert rule.include?(Time.local(2016, 1, 1)) }
    it { assert rule.include?(Time.local(2015, 4, 10)) }
    it { assert rule.include?(Time.local(2016, 4, 9)) }
    it { assert rule.include?(Time.local(2015, 12, 31)) }
    it { assert rule.include?(Time.local(2016, 12, 31)) }
    it { refute rule.include?(Time.local(2015, 1, 2)) }
    it { refute rule.include?(Time.local(2016, 1, 2)) }
    it { refute rule.include?(Time.local(2015, 4, 11)) }
    it { refute rule.include?(Time.local(2016, 4, 8)) }
    it { refute rule.include?(Time.local(2015, 12, 30)) }
    it { refute rule.include?(Time.local(2016, 12, 30)) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
