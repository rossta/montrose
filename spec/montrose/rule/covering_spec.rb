# frozen_string_literal: true

require "spec_helper"

describe Montrose::Rule::Covering do
  let(:now) { Time.new(2015, 9, 3, 12, 0, 0, "-04:00") }

  let(:starts) { now - 1.days }
  let(:ends)   { now + 3.days }

  describe "time range" do
    let(:rule) { Montrose::Rule::Covering.new(starts..ends) }

    describe "#include?" do
      it { refute rule.include?(now - 10.days) }
      it { assert rule.include?(now) }
      it { refute rule.include?(now + 10.days) }
    end

    describe "#continue?" do
      it { assert rule.continue?(now - 10.days) }
      it { assert rule.continue?(now) }
      it { refute rule.continue?(now + 10.days) }
    end
  end

  describe "date range" do
    let(:rule) { Montrose::Rule::Covering.new((starts.to_date)..(ends.to_date)) }

    describe "#include?" do
      it { refute rule.include?(now - 10.days) }

      # Testing time zone differences
      it { refute rule.include?(Time.new(2015, 9, 1, 19, 0, 0, "-04:00")) }
      it { refute rule.include?(Time.new(2015, 9, 1, 20, 0, 0, "-04:00")) }
      it { refute rule.include?(Time.new(2015, 9, 1, 21, 0, 0, "-04:00")) }

      it { refute rule.include?(Time.new(2015, 9, 1, 23, 0, 0, "-04:00")) }
      it { assert rule.include?(Time.new(2015, 9, 2, 00, 0, 0, "-04:00")) }
      it { assert rule.include?(Time.new(2015, 9, 2, 01, 0, 0, "-04:00")) }

      it { assert rule.include?(now - 1.days) }

      it { assert rule.include?(now) }
      it { assert rule.include?(now + 1.days) }

      it { assert rule.include?(Time.new(2015, 9, 6, 19, 0, 0, "-04:00")) }
      it { assert rule.include?(Time.new(2015, 9, 6, 20, 0, 0, "-04:00")) }
      it { assert rule.include?(Time.new(2015, 9, 6, 21, 0, 0, "-04:00")) }

      it { assert rule.include?(Time.new(2015, 9, 6, 23, 0, 0, "-04:00")) }
      it { refute rule.include?(Time.new(2015, 9, 7, 00, 0, 0, "-04:00")) }
      it { refute rule.include?(Time.new(2015, 9, 7, 01, 0, 0, "-04:00")) }

      it { refute rule.include?(now + 10.days) }
    end

    describe "#continue?" do
      it { assert rule.continue?(now - 10.days) }
      it { assert rule.continue?(now - 1.days) }
      it { assert rule.continue?(now) }
      it { assert rule.continue?(now + 1.days) }
      it { refute rule.continue?(now + 3.days) }
      it { refute rule.continue?(now + 10.days) }
    end
  end
end
