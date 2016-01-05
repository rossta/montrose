require "spec_helper"

describe Montrose::Options do
  let(:options) { new_options(every: :day) }

  describe "#every" do
    it "must be set" do
      -> { new_options(every: nil) }.must_raise
    end

    it "can be set" do
      options[:every] = :month

      options.every.must_equal :month
      options[:every].must_equal :month
    end

    it "must be a valid frequency" do
      -> { options[:every] = :nonsense }.must_raise
    end
  end

  describe "#starts" do
    before do
      Timecop.freeze(Time.now)
    end

    it "defaults to current time" do
      options.starts.must_equal Time.now
      options[:starts].must_equal Time.now
    end

    it "can be set" do
      options[:starts] = 3.days.from_now

      options.starts.must_equal 3.days.from_now
      options[:starts].must_equal 3.days.from_now
    end
  end

  describe "#interval" do
    it "defaults to 1" do
      options.interval.must_equal 1
      options[:interval].must_equal 1
    end

    it "can be set" do
      options[:interval] = 2

      options.interval.must_equal 2
      options[:interval].must_equal 2
    end
  end

  describe "#day" do
    it "defaults to nil" do
      options.day.must_be_nil
      options[:day].must_be_nil
    end

    it "casts day names to day numbers" do
      options[:day] = [:monday, :tuesday]

      options.day.must_equal [1, 2]
      options[:day].must_equal [1, 2]
    end

    it "casts to element to array" do
      options[:day] = :monday

      options.day.must_equal [1]
      options[:day].must_equal [1]
    end

    it "can set numbers" do
      options[:day] = 1

      options.day.must_equal [1]
      options[:day].must_equal [1]
    end

    it "sets" do
      options[:day] = 1

      options.day.must_equal [1]
      options[:day].must_equal [1]
    end
  end

  describe "#mday" do
    it "defaults to nil" do
      options.mday.must_be_nil
      options[:mday].must_be_nil
    end

    it "can be set" do
      options[:mday] = [1, 2, 3]

      options.mday.must_equal [1, 2, 3]
      options[:mday].must_equal [1, 2, 3]
    end

    it "casts to element to array" do
      options[:mday] = -1

      options.mday.must_equal [-1]
      options[:mday].must_equal [-1]
    end

    it "casts range to array" do
      options[:mday] = 6..8

      options.mday.must_equal [6, 7, 8]
      options[:mday].must_equal [6, 7, 8]
    end

    it "casts nil to empty array" do
      options[:mday] = nil

      options.day.must_be_nil
      options[:day].must_be_nil
    end

    it "raises exception for out of range" do
      -> { options[:mday] = [1, 100] }.must_raise
    end
  end

  describe "#yday" do
    it "defaults to nil" do
      options.yday.must_be_nil
      options[:yday].must_be_nil
    end

    it "can be set" do
      options[:yday] = [1, 2, 3]

      options.yday.must_equal [1, 2, 3]
      options[:yday].must_equal [1, 2, 3]
    end

    it "casts to element to array" do
      options[:yday] = -1

      options.yday.must_equal [-1]
      options[:yday].must_equal [-1]
    end

    it "casts range to array" do
      options[:yday] = 6..8

      options.yday.must_equal [6, 7, 8]
      options[:yday].must_equal [6, 7, 8]
    end

    it "casts nil to empty array" do
      options[:yday] = nil

      options.day.must_be_nil
      options[:day].must_be_nil
    end

    it "raises exception for out of range" do
      -> { options[:yday] = [1, 400] }.must_raise
    end
  end
end
# def_option :every
# def_option :starts
# def_option :until
# def_option :yday
# def_option :week
# def_option :month
# def_option :interval
# def_option :total
