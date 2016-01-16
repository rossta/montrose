require "spec_helper"

describe Montrose::Rule::MonthOfYear do
  let(:rule) { Montrose::Rule::MonthOfYear.new([1, 12]) }

  describe "#include?" do
    it { assert rule.include?(Time.local(2016, 1)) }
    it { refute rule.include?(Time.local(2016, 2)) }
    it { assert rule.include?(Time.local(2016, 12)) }
    it { refute rule.include?(Time.local(2016, 11)) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
