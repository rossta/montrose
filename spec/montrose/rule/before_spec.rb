require "spec_helper"

describe Montrose::Rule::Before do
  let(:rule) { Montrose::Rule::Before.new(time_now) }

  describe "#include?" do
    it { assert rule.include?(time_now - 10.days) }
    it { refute rule.include?(time_now) }
    it { refute rule.include?(time_now + 10.days) }
  end

  describe "#continue?" do
    it { refute rule.continue? }
  end
end
