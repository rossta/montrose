# frozen_string_literal: true

require "spec_helper"

describe Montrose::Rule::During do
  def time_of_day(*time_of_day_parts)
    Time.new(2015, 9, 3, *time_of_day_parts, "-04:00")
  end

  describe "single tuple" do
    let(:rule) { Montrose::Rule::During.new([[[9, 0, 0], [17, 0, 0]]]) }

    describe "#include?" do
      it { refute rule.include?(time_of_day(0, 0, 0)) }
      it { refute rule.include?(time_of_day(8, 59, 0)) }
      it { assert rule.include?(time_of_day(9, 0, 0)) }
      it { assert rule.include?(time_of_day(12, 0, 0)) }
      it { assert rule.include?(time_of_day(17, 0, 0)) }
      it { refute rule.include?(time_of_day(17, 1, 0)) }
      it { refute rule.include?(time_of_day(23, 59, 0)) }
    end
  end

  describe "multiple tuples" do
    let(:rule) {
      Montrose::Rule::During.new([
        [[9, 0, 0], [11, 0, 0]],
        [[12, 0, 0], [14, 0, 0]]
      ])
    }

    describe "#include?" do
      it { refute rule.include?(time_of_day(0, 0, 0)) }
      it { refute rule.include?(time_of_day(8, 59, 0)) }
      it { assert rule.include?(time_of_day(9, 0, 0)) }
      it { assert rule.include?(time_of_day(10, 0, 0)) }
      it { assert rule.include?(time_of_day(11, 0, 0)) }
      it { refute rule.include?(time_of_day(11, 30, 0)) }
      it { assert rule.include?(time_of_day(12, 0, 0)) }
      it { assert rule.include?(time_of_day(13, 0, 0)) }
      it { assert rule.include?(time_of_day(14, 0, 0)) }
      it { refute rule.include?(time_of_day(17, 0, 0)) }
      it { refute rule.include?(time_of_day(17, 1, 0)) }
      it { refute rule.include?(time_of_day(23, 59, 0)) }
    end
  end

  describe "exclude end" do
    let(:rule) { Montrose::Rule::During.new(during: [[[9, 0, 0], [17, 0, 0]]], exclude_end: true) }

    describe "#include?" do
      it { refute rule.include?(time_of_day(0, 0, 0)) }
      it { refute rule.include?(time_of_day(8, 59, 0)) }
      it { assert rule.include?(time_of_day(9, 0, 0)) }
      it { assert rule.include?(time_of_day(12, 0, 0)) }
      it { refute rule.include?(time_of_day(17, 0, 0)) }
      it { refute rule.include?(time_of_day(17, 1, 0)) }
      it { refute rule.include?(time_of_day(23, 59, 0)) }
    end
  end
end
