# frozen_string_literal: true
require "spec_helper"

describe Montrose::Rule::Total do
  let(:rule) { Montrose::Rule::Total.new(max) }
  let(:max) { 3 }

  describe "#include?" do
    it "is true before advancing" do
      assert rule.include?(Time.current)
    end

    it "is true after advancing to the max" do
      rule.advance!(Time.current)
      rule.advance!(Time.current)
      rule.advance!(Time.current)

      assert rule.include?(Time.now)
    end

    it "is true after advancing to the max" do
      rule.advance!(Time.current)
      rule.advance!(Time.current)
      rule.advance!(Time.current)
      rule.advance!(Time.current)

      refute rule.include?(Time.current)
    end
  end

  describe "#continue?" do
    it { assert rule.continue?(time_now) }
  end
end
