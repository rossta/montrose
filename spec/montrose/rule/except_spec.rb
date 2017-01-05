# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::Except do
  let(:dates) { [Date.today, Date.today + 5.days] }
  let(:rule)  { Montrose::Rule::Except.new(dates) }

  describe "#include?" do
    it { refute rule.include?(time_now) }
    it { assert rule.include?(time_now + 1.days) }
    it { refute rule.include?(time_now + 5.days) }
    it { assert rule.include?(time_now + 10.days) }
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
