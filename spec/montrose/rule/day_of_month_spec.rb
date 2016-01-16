require "spec_helper"

describe Montrose::Rule::DayOfMonth do
  let(:rule) { Montrose::Rule::DayOfMonth.new([1, 10, -1]) }

  describe "#include?" do
    it { assert rule.include?(Time.local(2016, 1, 1)) }
    it { assert rule.include?(Time.local(2016, 1, 10)) }
    it { assert rule.include?(Time.local(2016, 1, 31)) }
    it { assert rule.include?(Time.local(2015, 2, 28)) }
    it { assert rule.include?(Time.local(2016, 2, 29)) }
    it { refute rule.include?(Time.local(2015, 1, 2)) }
    it { refute rule.include?(Time.local(2015, 1, 30)) }
    it { refute rule.include?(Time.local(2015, 2, 27)) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
