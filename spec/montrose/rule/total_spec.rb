require "spec_helper"

describe Montrose::Rule::Total do
  let(:rule) { Montrose::Rule::Total.new(max) }
  let(:max) { 3 }

  describe "#include?" do
    it "is true before advancing" do
      assert rule.include?(Time.now)
    end

    it "is true after advancing to the max" do
      rule.advance!(Time.now)
      rule.advance!(Time.now)
      rule.advance!(Time.now)

      assert rule.include?(Time.now)
    end

    it "is true after advancing to the max" do
      rule.advance!(Time.now)
      rule.advance!(Time.now)
      rule.advance!(Time.now)
      rule.advance!(Time.now)

      refute rule.include?(Time.now)
    end
  end

  describe "#continue?" do
    it { assert rule.continue? }
  end
end
