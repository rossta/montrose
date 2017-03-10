# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::Between do
  let(:rule) { Montrose::Rule::Between.new(1.day.ago..3.days.from_now) }

  describe "#include?" do
    it { refute rule.include?(time_now - 10.days) }
    it { assert rule.include?(time_now) }
    it { refute rule.include?(time_now + 10.days) }
  end

  describe "#continue?" do
    it { assert rule.continue?(time_now - 10.days) }
    it { assert rule.continue?(time_now) }
    it { refute rule.continue?(time_now + 10.days) }
  end
end
