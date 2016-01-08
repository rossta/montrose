require "spec_helper"

describe Montrose::Options do
  let(:options) { new_options }

  describe "#every" do
    after do
      Montrose::Options.default_every = nil
    end

    it "defaults to nil" do
      options.every.must_be_nil
      options[:every].must_be_nil
    end

    it "defaults to default_frequency time" do
      Montrose::Options.default_every = :month

      options.every.must_equal :month
      options[:every].must_equal :month
    end

    it "can be set" do
      options[:every] = :month

      options.every.must_equal :month
      options[:every].must_equal :month
    end

    it "must be a valid frequency" do
      -> { options[:every] = :nonsense }.must_raise
    end

    describe "from integer" do
      it "parses as every: :minute with interval" do
        options[:every] = 30.minutes

        options[:every].must_equal :minute
        options[:interval].must_equal 30

        options[:every] = 90.minutes

        options[:every].must_equal :minute
        options[:interval].must_equal 90
      end

      it "parses as every: :hour, with interval" do
        options[:every] = 1.hour

        options[:every].must_equal :hour
        options[:interval].must_equal 1

        options[:every] = 5.hours

        options[:every].must_equal :hour
        options[:interval].must_equal 5
      end

      it "parses as every: :week, with interval" do
        options[:every] = 1.week

        options[:every].must_equal :week
        options[:interval].must_equal 1

        options[:every] = 12.weeks

        options[:every].must_equal :week
        options[:interval].must_equal 12
      end

      it "parses as every: :month, with interval" do
        options[:every] = 1.month

        options[:every].must_equal :month
        options[:interval].must_equal 1

        options[:every] = 12.months

        options[:every].must_equal :month
        options[:interval].must_equal 12
      end

      it "parses as every: :year, with interval" do
        options[:every] = 1.year

        options[:every].must_equal :year
        options[:interval].must_equal 1

        options[:every] = 12.years

        options[:every].must_equal :year
        options[:interval].must_equal 12
      end

      it "parses on initialize, ignores given interval" do
        options = new_options(every: 5.years, interval: 2)

        options[:every].must_equal :year
        options[:interval].must_equal 5
      end
    end
  end

  describe "#starts" do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Montrose::Options.default_starts = nil
    end

    it "defaults to current time" do
      options.starts.must_equal Time.now
      options[:starts].must_equal Time.now
    end

    it "defaults to default_ends_at time" do
      Montrose::Options.default_starts = 3.days.from_now

      options.starts.must_equal 3.days.from_now
      options[:starts].must_equal 3.days.from_now
    end

    it "can be set" do
      options[:starts] = 3.days.from_now

      options.starts.must_equal 3.days.from_now
      options[:starts].must_equal 3.days.from_now
    end

    it "can't be nil" do
      options[:starts] = nil

      options.starts.must_equal Time.now
      options[:starts].must_equal Time.now
    end

    it "parses string" do
      options[:starts] = "2015-09-01"

      options.starts.must_equal Time.parse("2015-09-01")
      options[:starts].must_equal Time.parse("2015-09-01")
    end

    it "converts Date to Time" do
      date = Date.parse("2015-09-01")
      options[:starts] = date

      options.starts.must_equal date.to_time
      options[:starts].must_equal date.to_time
    end
  end

  describe "#until" do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Montrose::Options.default_ends = nil
    end

    it "defaults to nil" do
      options.until.must_be_nil
      options[:until].must_be_nil
    end

    it "defaults to default_ends time" do
      Montrose::Options.default_ends = 3.days.from_now

      options.until.must_equal 3.days.from_now
      options[:until].must_equal 3.days.from_now
    end

    it "can be set" do
      options[:until] = 3.days.from_now

      options.until.must_equal 3.days.from_now
      options[:until].must_equal 3.days.from_now
    end

    it "parses string" do
      options[:until] = "2015-09-01"

      options.until.must_equal Time.parse("2015-09-01")
      options[:until].must_equal Time.parse("2015-09-01")
    end

    it "converts Date to Time" do
      date = Date.parse("2015-09-01")
      options[:until] = date

      options.until.must_equal date.to_time
      options[:until].must_equal date.to_time
    end
  end

  describe "#between" do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Montrose::Options.default_starts = nil
    end

    it "sets starts and until times" do
      options[:between] = Date.today..1.month.from_now.to_date

      options.starts.must_equal Date.today.to_time
      options.until.must_equal 1.month.from_now.beginning_of_day
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

  describe "#total" do
    it "defaults to nil" do
      options.total.must_be_nil
      options[:total].must_be_nil
    end

    it "can be set" do
      options[:total] = 2

      options.total.must_equal 2
      options[:total].must_equal 2
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

    describe "nested hash" do
      it "converts day name keys" do
        options[:day] = { friday: [1] }

        options.day.must_equal(5 => [1])
        options[:day].must_equal(5 => [1])
      end

      it "casts day number values to arrays" do
        options[:day] = { 5 => 1 }

        options.day.must_equal(5 => [1])
        options[:day].must_equal(5 => [1])
      end
    end
  end

  describe "#mday" do
    it "defaults to nil" do
      options.mday.must_be_nil
      options[:mday].must_be_nil
    end

    it "can be set" do
      options[:mday] = [1, 20, 31]

      options.mday.must_equal [1, 20, 31]
      options[:mday].must_equal [1, 20, 31]
    end

    it "casts to element to array" do
      options[:mday] = 1

      options.mday.must_equal [1]
      options[:mday].must_equal [1]
    end

    it "allows negative numbers" do
      options[:yday] = [-1]

      options.yday.must_equal [-1]
      options[:yday].must_equal [-1]
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

    it "raises for out of range" do
      -> { options[:mday] = [1, 100] }.must_raise
    end
  end

  describe "#yday" do
    it "defaults to nil" do
      options.yday.must_be_nil
      options[:yday].must_be_nil
    end

    it "can be set" do
      options[:yday] = [1, 200, 366]

      options.yday.must_equal [1, 200, 366]
      options[:yday].must_equal [1, 200, 366]
    end

    it "casts to element to array" do
      options[:yday] = 1

      options.yday.must_equal [1]
      options[:yday].must_equal [1]
    end

    it "allows negative numbers" do
      options[:yday] = [-1]

      options.yday.must_equal [-1]
      options[:yday].must_equal [-1]
    end

    it "casts range to array" do
      options[:yday] = 6..8

      options.yday.must_equal [6, 7, 8]
      options[:yday].must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:yday] = nil

      options.day.must_be_nil
      options[:day].must_be_nil
    end

    it "raises for out of range" do
      -> { options[:yday] = [1, 400] }.must_raise
    end
  end

  describe "#week" do
    it "defaults to nil" do
      options.week.must_be_nil
      options[:week].must_be_nil
    end

    it "can be set" do
      options[:week] = [1, 10, 53]

      options.week.must_equal [1, 10, 53]
      options[:week].must_equal [1, 10, 53]
    end

    it "casts element to array" do
      options[:week] = 1

      options.week.must_equal [1]
      options[:week].must_equal [1]
    end

    it "allows negative numbers" do
      options[:week] = [-1]

      options.week.must_equal [-1]
      options[:week].must_equal [-1]
    end

    it "casts range to array" do
      options[:week] = 6..8

      options.week.must_equal [6, 7, 8]
      options[:week].must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:week] = nil

      options.week.must_be_nil
      options[:week].must_be_nil
    end

    it "raises for out of range" do
      -> { options[:week] = [1, 56] }.must_raise
    end

    it "raises for negative out of range" do
      -> { options[:hour] = -1 }.must_raise
    end
  end

  describe "#month" do
    it "defaults to nil" do
      options.month.must_be_nil
      options[:month].must_be_nil
    end

    it "can be set by month number" do
      options[:month] = [1, 12]

      options.month.must_equal [1, 12]
      options[:month].must_equal [1, 12]
    end

    it "casts month names to month numbers" do
      options[:month] = [:january, :december]

      options.month.must_equal [1, 12]
      options[:month].must_equal [1, 12]

      options[:month] = %w[january december]

      options.month.must_equal [1, 12]
      options[:month].must_equal [1, 12]

      options[:month] = %w[January December]

      options.month.must_equal [1, 12]
      options[:month].must_equal [1, 12]
    end

    it "casts element to array" do
      options[:month] = 1

      options.month.must_equal [1]
      options[:month].must_equal [1]
    end

    it "casts range to array" do
      options[:month] = 6..8

      options.month.must_equal [6, 7, 8]
      options[:month].must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:month] = nil

      options.month.must_be_nil
      options[:month].must_be_nil
    end

    it "raises for out of range" do
      -> { options[:month] = [1, 13] }.must_raise
    end

    it "raises for negative out of range" do
      -> { options[:month] = -1 }.must_raise
    end
  end

  describe "#hour" do
    it "defaults to nil" do
      options.hour.must_be_nil
      options[:hour].must_be_nil
    end

    it "can be set by hour number" do
      options[:hour] = [1, 24]

      options.hour.must_equal [1, 24]
      options[:hour].must_equal [1, 24]
    end

    it "casts element to array" do
      options[:hour] = 1

      options.hour.must_equal [1]
      options[:hour].must_equal [1]
    end

    it "casts range to array" do
      options[:hour] = 6..8

      options.hour.must_equal [6, 7, 8]
      options[:hour].must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:hour] = nil

      options.hour.must_be_nil
      options[:hour].must_be_nil
    end

    it "raises for out of range" do
      -> { options[:hour] = [1, 25] }.must_raise
    end

    it "raises for negative out of range" do
      -> { options[:hour] = -1 }.must_raise
    end
  end

  describe "#to_hash" do
    let(:options) { new_options(every: :day) }

    before do
      Timecop.freeze(Time.now)
    end

    it "returns Hash with non-nil key-value pairs" do
      options.to_hash.must_equal(
        every: :day,
        starts: Time.now,
        interval: 1)
    end
  end

  describe "#fetch" do
    it "returns key if present" do
      options[:every] = :month

      options.fetch(:every).must_equal :month
    end

    it "returns default if given" do
      options.fetch(:every, :foo).must_equal :foo
    end

    it "return nil if given as default" do
      options.fetch(:every, nil).must_be_nil
    end

    it "calls block if not found" do
      options.fetch(:every) { :foo }.must_equal :foo
    end

    it "raises for no block given and value not found" do
      -> { options.fetch(:every) }.must_raise
    end

    it "raises for more than two args" do
      -> { options.fetch(:every, nil, nil) }.must_raise
    end
  end
end
