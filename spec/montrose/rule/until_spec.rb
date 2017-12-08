# frozen_string_literal: true

require "spec_helper"

describe Montrose::Rule::Until do
  describe "include end" do
    let(:rule) { Montrose::Rule::Until.new(until: time_now, exclude_end: false) }

    describe "#include?" do
      it { assert rule.include?(time_now - 10.days) }
      it { assert rule.include?(time_now) }
      it { refute rule.include?(time_now + 10.days) }
    end

    describe "#continue?" do
      it { refute rule.continue?(time_now) }
    end
  end

  describe "exclude end" do
    let(:rule) { Montrose::Rule::Until.new(until: time_now, exclude_end: true) }

    describe "#include?" do
      it { assert rule.include?(time_now - 10.days) }
      it { refute rule.include?(time_now) }
      it { refute rule.include?(time_now + 10.days) }
    end

    describe "#continue?" do
      it { refute rule.continue?(time_now) }
    end
  end
end
