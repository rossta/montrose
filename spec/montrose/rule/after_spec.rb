# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::After do
  let(:rule) { Montrose::Rule::After.new(time_now) }

  describe "#include?" do
    it { assert rule.include?(time_now) }
    it { assert rule.include?(time_now + 10.days) }
    it { refute rule.include?(time_now - 10.days) }
  end

  describe "#continue?" do
    it { refute rule.continue? }
  end
end
