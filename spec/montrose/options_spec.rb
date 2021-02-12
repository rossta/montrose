# frozen_string_literal: true

require "spec_helper"

describe Montrose::Options do
  let(:options) { new_options }

  it { _(Montrose::Options.new(nil)).must_be_instance_of(Montrose::Options) }

  describe "#start_time" do
    before do
      Timecop.freeze(time_now)
    end

    after do
      Montrose::Options.default_starts = nil
    end

    it "defaults to :starts" do
      options[:starts] = 3.days.from_now

      _(options.start_time).must_equal 3.days.from_now
      _(options[:start_time]).must_equal 3.days.from_now
    end

    it "defaults to default_starts time" do
      Montrose::Options.default_starts = 3.days.from_now

      _(options.start_time).must_equal 3.days.from_now
      _(options[:start_time]).must_equal 3.days.from_now
    end

    it "cannot be set" do
      _(-> { options[:start_time] = 3.days.from_now }).must_raise
    end

    it "is :at time on default_starts date" do
      noon = Time.local(2015, 9, 1, 12)
      Timecop.freeze(noon)
      options[:at] = "7pm"

      _(options[:start_time]).must_equal Time.local(2015, 9, 1, 19)
    end

    it "is current time despite :at time earlier in day" do
      options[:starts] = Time.local(2019, 12, 25, 20)
      options[:at] = %w[7pm 10am]

      _(options[:start_time]).must_equal Time.local(2019, 12, 25, 20)
    end

    it "is :starts when :at empty" do
      options[:starts] = Time.local(2019, 12, 25, 20)
      options[:at] = []

      _(options[:start_time]).must_equal Time.local(2019, 12, 25, 20)
    end
  end

  describe ".default_starts" do
    after do
      Montrose::Options.default_starts = nil
    end

    it "accepts time" do
      Montrose::Options.default_starts = Time.local(2016, 9, 2, 12)

      _(Montrose::Options.default_starts).must_equal Time.local(2016, 9, 2, 12)
    end

    it "accepts string" do
      Montrose::Options.default_starts = "September 2, 2016 at 12 PM"

      _(Montrose::Options.default_starts).must_equal Time.local(2016, 9, 2, 12)
    end

    it "accepts proc" do
      Montrose::Options.default_starts = -> { Time.local(2016, 9, 2, 12) }

      _(Montrose::Options.default_starts).must_equal Time.local(2016, 9, 2, 12)
    end
  end

  describe ".default_until" do
    after do
      Montrose::Options.default_until = nil
    end

    it "accepts time" do
      Montrose::Options.default_until = Time.local(2016, 9, 2, 12)

      _(Montrose::Options.default_until).must_equal Time.local(2016, 9, 2, 12)
    end

    it "accepts string" do
      Montrose::Options.default_until = "September 2, 2016 at 12 PM"

      _(Montrose::Options.default_until).must_equal Time.local(2016, 9, 2, 12)
    end

    it "accepts proc" do
      Montrose::Options.default_until = -> { Time.local(2016, 9, 2, 12) }

      _(Montrose::Options.default_until).must_equal Time.local(2016, 9, 2, 12)
    end
  end

  describe "#every" do
    after do
      Montrose::Options.default_every = nil
    end

    it "defaults to nil" do
      _(options.every).must_be_nil
      _(options[:every]).must_be_nil
    end

    it "defaults to default_frequency time" do
      Montrose::Options.default_every = :month

      _(options.every).must_equal :month
      _(options[:every]).must_equal :month
    end

    it "can be set with valid symbol name" do
      options[:every] = :month

      _(options.every).must_equal :month
      _(options[:every]).must_equal :month
    end

    it "can be set with valid string name" do
      options[:every] = "month"

      _(options.every).must_equal :month
      _(options[:every]).must_equal :month
    end

    it "must be a valid frequency" do
      _(-> { options[:every] = :nonsense }).must_raise
    end

    it "aliases to :frequency" do
      options[:frequency] = "month"

      _(options.every).must_equal :month
      _(options[:every]).must_equal :month
      _(options[:frequency]).must_equal :month
    end

    describe "from integer" do
      it "parses as every: :minute with interval" do
        options[:every] = 30.minutes

        _(options_duration(options)).must_equal 30.minutes

        options[:every] = 90.minutes

        _(options_duration(options)).must_equal 90.minutes
      end

      it "parses as every: :hour, with interval" do
        options[:every] = 1.hour

        _(options_duration(options)).must_equal 1.hour

        options[:every] = 5.hours

        _(options_duration(options)).must_equal 5.hours
      end

      it "parses as every: :day, with interval" do
        options[:every] = 1.day

        _(options_duration(options)).must_equal 1.day

        options[:every] = 30.days

        _(options_duration(options)).must_equal 30.days
      end

      it "parses as every: :week, with interval" do
        options[:every] = 1.week

        _(options_duration(options)).must_equal 1.week

        options[:every] = 12.weeks

        _(options_duration(options)).must_equal 12.weeks
      end

      it "parses as every: :month, with interval" do
        options[:every] = 1.month

        _(options_duration(options)).must_equal 1.month

        options[:every] = 12.months

        _(options_duration(options)).must_equal 12.months
      end

      it "parses as every: :year, with interval" do
        options[:every] = 1.year

        _(options_duration(options)).must_equal 1.year

        options[:every] = 12.years

        _(options_duration(options)).must_equal 12.years
      end

      it "parses on initialize, ignores given interval" do
        options = new_options(every: 5.years, interval: 2)

        _(options_duration(options)).must_equal 5.years
      end
    end
  end

  describe "#starts" do
    before do
      Timecop.freeze(time_now)
    end

    it "can be set" do
      options[:starts] = 3.days.from_now

      _(options.starts).must_equal 3.days.from_now
      _(options[:starts]).must_equal 3.days.from_now
    end

    it "can't be nil" do
      options[:starts] = nil

      _(options.starts).must_equal time_now
      _(options[:starts]).must_equal time_now
    end

    it "parses string" do
      options[:starts] = "2015-09-01"

      _(options.starts).must_equal Time.parse("2015-09-01")
      _(options[:starts]).must_equal Time.parse("2015-09-01")
    end

    it "converts Date to Time" do
      date = Date.parse("2015-09-01")
      options[:starts] = date

      _(options.starts).must_equal date.to_time
      _(options[:starts]).must_equal date.to_time
    end
  end

  describe "#until" do
    before do
      Timecop.freeze(time_now)
    end

    after do
      Montrose::Options.default_until = nil
    end

    it "defaults to nil" do
      _(options.until).must_be_nil
      _(options[:until]).must_be_nil
    end

    it "defaults to default_until time" do
      Montrose::Options.default_until = 3.days.from_now
      default = Montrose::Options.merge(options)

      _(default.until).must_equal 3.days.from_now
      _(default[:until]).must_equal 3.days.from_now
    end

    it "can be set" do
      options[:until] = 3.days.from_now

      _(options.until).must_equal 3.days.from_now
      _(options[:until]).must_equal 3.days.from_now
    end

    it "parses string" do
      options[:until] = "2015-09-01"

      _(options.until).must_equal Time.parse("2015-09-01")
      _(options[:until]).must_equal Time.parse("2015-09-01")
    end

    it "converts Date to Time" do
      date = Date.parse("2015-09-01")
      options[:until] = date

      _(options.until).must_equal date.to_time
      _(options[:until]).must_equal date.to_time
    end
  end

  describe "#between" do
    before do
      Timecop.freeze(time_now)
    end

    after do
      Montrose::Options.default_starts = nil
    end

    it "sets starts and until times" do
      options[:between] = Date.today..1.month.from_now.to_date

      _(options.starts).must_equal Date.today.to_time
      _(options.until).must_equal 1.month.from_now.beginning_of_day
    end

    it "defers to separate starts time outside of range" do
      options[:between] = Date.today..1.month.from_now.to_date
      options[:starts] = 1.day.ago

      _(options.starts).must_equal 1.day.ago.to_time
    end

    it "defers to separate starts time within range" do
      options[:between] = Date.today..1.month.from_now.to_date
      options[:starts] = 1.day.from_now

      _(options.starts).must_equal 1.day.from_now.to_time
    end
  end

  describe "#covering" do
    before do
      Timecop.freeze(time_now)
    end

    it "returns given date range" do
      options[:covering] = Date.today..1.month.from_now.to_date

      _(options.covering).must_equal(Date.today..1.month.from_now.to_date)
    end
  end

  describe "#interval" do
    it "defaults to 1" do
      default = Montrose::Options.merge(options)

      _(default.interval).must_equal 1
      _(default[:interval]).must_equal 1
    end

    it "can be set" do
      options[:interval] = 2

      _(options.interval).must_equal 2
      _(options[:interval]).must_equal 2
    end
  end

  describe "#total" do
    it "defaults to nil" do
      _(options.total).must_be_nil
      _(options[:total]).must_be_nil
    end

    it "can be set" do
      options[:total] = 2

      _(options.total).must_equal 2
      _(options[:total]).must_equal 2
    end
  end

  describe "#day" do
    it "defaults to nil" do
      _(options.day).must_be_nil
      _(options[:day]).must_be_nil
    end

    it "casts day names to day numbers" do
      options[:day] = %i[monday tuesday]

      _(options.day).must_equal [1, 2]
      _(options[:day]).must_equal [1, 2]
    end

    it "casts to element to array" do
      options[:day] = :monday

      _(options.day).must_equal [1]
      _(options[:day]).must_equal [1]
    end

    it "can set numbers" do
      options[:day] = 1

      _(options.day).must_equal [1]
      _(options[:day]).must_equal [1]
    end

    describe "nested hash" do
      it "converts day name keys" do
        options[:day] = {friday: [1]}

        _(options.day).must_equal(5 => [1])
        _(options[:day]).must_equal(5 => [1])
      end

      it "casts day number values to arrays" do
        options[:day] = {5 => 1}

        _(options.day).must_equal(5 => [1])
        _(options[:day]).must_equal(5 => [1])
      end
    end
  end

  describe "#mday" do
    it "defaults to nil" do
      _(options.mday).must_be_nil
      _(options[:mday]).must_be_nil
    end

    it "can be set" do
      options[:mday] = [1, 20, 31]

      _(options.mday).must_equal [1, 20, 31]
      _(options[:mday]).must_equal [1, 20, 31]
    end

    it "casts to element to array" do
      options[:mday] = 1

      _(options.mday).must_equal [1]
      _(options[:mday]).must_equal [1]
    end

    it "allows negative numbers" do
      options[:yday] = [-1]

      _(options.yday).must_equal [-1]
      _(options[:yday]).must_equal [-1]
    end

    it "casts range to array" do
      options[:mday] = 6..8

      _(options.mday).must_equal [6, 7, 8]
      _(options[:mday]).must_equal [6, 7, 8]
    end

    it "casts nil to empty array" do
      options[:mday] = nil

      _(options.day).must_be_nil
      _(options[:day]).must_be_nil
    end

    it "raises for out of range" do
      _(-> { options[:mday] = [1, 100] }).must_raise
    end
  end

  describe "#yday" do
    it "defaults to nil" do
      _(options.yday).must_be_nil
      _(options[:yday]).must_be_nil
    end

    it "can be set" do
      options[:yday] = [1, 200, 366]

      _(options.yday).must_equal [1, 200, 366]
      _(options[:yday]).must_equal [1, 200, 366]
    end

    it "casts to element to array" do
      options[:yday] = 1

      _(options.yday).must_equal [1]
      _(options[:yday]).must_equal [1]
    end

    it "allows negative numbers" do
      options[:yday] = [-1]

      _(options.yday).must_equal [-1]
      _(options[:yday]).must_equal [-1]
    end

    it "casts range to array" do
      options[:yday] = 6..8

      _(options.yday).must_equal [6, 7, 8]
      _(options[:yday]).must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:yday] = nil

      _(options.day).must_be_nil
      _(options[:day]).must_be_nil
    end

    it "raises for out of range" do
      _(-> { options[:yday] = [1, 400] }).must_raise
    end
  end

  describe "#week" do
    it "defaults to nil" do
      _(options.week).must_be_nil
      _(options[:week]).must_be_nil
    end

    it "can be set" do
      options[:week] = [1, 10, 53]

      _(options.week).must_equal [1, 10, 53]
      _(options[:week]).must_equal [1, 10, 53]
    end

    it "casts element to array" do
      options[:week] = 1

      _(options.week).must_equal [1]
      _(options[:week]).must_equal [1]
    end

    it "allows negative numbers" do
      options[:week] = [-1]

      _(options.week).must_equal [-1]
      _(options[:week]).must_equal [-1]
    end

    it "casts range to array" do
      options[:week] = 6..8

      _(options.week).must_equal [6, 7, 8]
      _(options[:week]).must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:week] = nil

      _(options.week).must_be_nil
      _(options[:week]).must_be_nil
    end

    it "raises for out of range" do
      _(-> { options[:week] = [1, 56] }).must_raise
    end

    it "raises for negative out of range" do
      _(-> { options[:hour] = -1 }).must_raise
    end
  end

  describe "#month" do
    it "defaults to nil" do
      _(options.month).must_be_nil
      _(options[:month]).must_be_nil
    end

    it "can be set by month number" do
      options[:month] = [1, 12]

      _(options.month).must_equal [1, 12]
      _(options[:month]).must_equal [1, 12]
    end

    it "casts month names to month numbers" do
      options[:month] = %i[january december]

      _(options.month).must_equal [1, 12]
      _(options[:month]).must_equal [1, 12]

      options[:month] = %w[january december]

      _(options.month).must_equal [1, 12]
      _(options[:month]).must_equal [1, 12]

      options[:month] = %w[January December]

      _(options.month).must_equal [1, 12]
      _(options[:month]).must_equal [1, 12]
    end

    it "casts element to array" do
      options[:month] = 1

      _(options.month).must_equal [1]
      _(options[:month]).must_equal [1]
    end

    it "casts range to array" do
      options[:month] = 6..8

      _(options.month).must_equal [6, 7, 8]
      _(options[:month]).must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:month] = nil

      _(options.month).must_be_nil
      _(options[:month]).must_be_nil
    end

    it "raises for out of range" do
      _(-> { options[:month] = [1, 13] }).must_raise
    end

    it "raises for negative out of range" do
      _(-> { options[:month] = -1 }).must_raise
    end
  end

  describe "#hour" do
    it "defaults to nil" do
      _(options.hour).must_be_nil
      _(options[:hour]).must_be_nil
    end

    it "can be set by hour number" do
      options[:hour] = [1, 24]

      _(options.hour).must_equal [1, 24]
      _(options[:hour]).must_equal [1, 24]
    end

    it "casts element to array" do
      options[:hour] = 1

      _(options.hour).must_equal [1]
      _(options[:hour]).must_equal [1]
    end

    it "casts range to array" do
      options[:hour] = 6..8

      _(options.hour).must_equal [6, 7, 8]
      _(options[:hour]).must_equal [6, 7, 8]
    end

    it "can be set to nil" do
      options[:hour] = nil

      _(options.hour).must_be_nil
      _(options[:hour]).must_be_nil
    end

    it "raises for out of range" do
      _(-> { options[:hour] = [1, 25] }).must_raise
    end

    it "raises for negative out of range" do
      _(-> { options[:hour] = -1 }).must_raise
    end
  end

  describe "#during" do
    it "defaults to nil" do
      _(options.during).must_be_nil
      _(options[:during]).must_be_nil
    end

    it "handles ranges of time" do
      range = Time.parse("9am")..Time.parse("5pm")
      options[:during] = range

      _(options.during).must_equal [[[9, 0, 0], [17, 0, 0]]]
      _(options[:during]).must_equal [[[9, 0, 0], [17, 0, 0]]]
    end

    it "handles string of beginning and end times" do
      options[:during] = "9am - 5pm"

      _(options.during).must_equal [[[9, 0, 0], [17, 0, 0]]]
      _(options[:during]).must_equal [[[9, 0, 0], [17, 0, 0]]]
    end

    it "can be set by an array time ranges" do
      range_1 = Time.parse("9am")..Time.parse("5pm")
      range_2 = "7:30pm-11:30pm"
      options[:during] = [range_1, range_2]

      _(options.during).must_equal [[[9, 0, 0], [17, 0, 0]], [[19, 30, 0], [23, 30, 0]]]
      _(options[:during]).must_equal [[[9, 0, 0], [17, 0, 0]], [[19, 30, 0], [23, 30, 0]]]
    end

    it "can be set by an array time arrays" do
      options[:during] = [[[9, 0, 0], [17, 0, 0]], [[19, 30, 0], [23, 30, 0]]]

      _(options.during).must_equal [[[9, 0, 0], [17, 0, 0]], [[19, 30, 0], [23, 30, 0]]]
      _(options[:during]).must_equal [[[9, 0, 0], [17, 0, 0]], [[19, 30, 0], [23, 30, 0]]]
    end

    it "splits args parts before and after midnight when spanning overnight" do
      options[:during] = "5pm - 9am"

      _(options.during).must_equal [[[17, 0, 0], [23, 59, 59]], [[0, 0, 0], [9, 0, 0]]]
      _(options[:during]).must_equal [[[17, 0, 0], [23, 59, 59]], [[0, 0, 0], [9, 0, 0]]]
    end

    it "can be set to nil" do
      options[:during] = nil

      _(options.during).must_be_nil
      _(options[:during]).must_be_nil
    end
  end

  describe "#at" do
    before do
      Timecop.freeze(Time.local(2015, 9, 1, 12))
    end

    it "defaults to nil" do
      _(options.at).must_be_nil
      _(options[:at]).must_be_nil
    end

    it "sets :at to hour, min, sec parts" do
      options[:at] = "3:30 PM"

      time = Time.parse("3:30 PM")
      _(options.at).must_equal [[time.hour, time.min, time.sec]]
      _(options[:at]).must_equal [[time.hour, time.min, time.sec]]
    end

    it "accepts an array of time strings" do
      options[:at] = ["10:30 AM", "3:45 PM"]

      time_1 = Time.local(2015, 9, 1, 10, 30)
      time_2 = Time.local(2015, 9, 1, 15, 45)
      _(options[:at]).must_equal [[time_1.hour, time_1.min, time_1.sec], [time_2.hour, time_2.min, time_2.sec]]
    end

    it "retains seconds info" do
      options[:at] = "23:59:59"

      time = Time.parse("23:59:59")

      _(options.at).must_equal [[time.hour, time.min, time.sec]]
      _(options[:at]).must_equal [[time.hour, time.min, time.sec]]
    end

    it "accepts an array of time part arrays" do
      options[:at] = [[10, 30], [15, 45]]

      time_1 = Time.local(2015, 9, 1, 10, 30)
      time_2 = Time.local(2015, 9, 1, 15, 45)
      _(options[:at]).must_equal [[time_1.hour, time_1.min], [time_2.hour, time_2.min]]
    end
  end

  describe "#on" do
    it "decomposes day name to wday" do
      options[:on] = :friday

      _(options[:day]).must_equal [5]
      _(options[:on]).must_equal :friday
    end

    it "decomposes day name => month day to wday and mday" do
      options[:on] = {friday: 13}

      _(options[:day]).must_equal [5]
      _(options[:mday]).must_equal [13]
      _(options[:on]).must_equal(friday: 13)
    end

    it "decomposes day name => month day to wday and mday as range" do
      options[:month] = :november
      options[:on] = {tuesday: 2..8}

      _(options[:day]).must_equal [2]
      _(options[:mday]).must_equal((2..8).to_a)
      _(options[:month]).must_equal [11]
    end

    it "decompose month name => month day to month and mday" do
      options[:on] = {january: 31}

      _(options[:month]).must_equal [1]
      _(options[:mday]).must_equal [31]
    end

    it { _(-> { options[:on] = -3 }).must_raise Montrose::ConfigurationError }
  end

  describe "#except" do
    it "defaults to nil" do
      _(options.except).must_be_nil
      _(options[:except]).must_be_nil
    end

    it "accepts a single date" do
      options[:except] = "2016-03-01"
      _(options[:except]).must_equal ["2016-03-01".to_date]
    end

    it "accepts multiple dates" do
      options[:except] = [Date.today, "2016-03-01"]
      _(options[:except]).must_equal [Date.today, "2016-03-01".to_date]
    end
  end

  describe "#to_hash" do
    let(:options) { new_options(every: :day) }

    before do
      Timecop.freeze(time_now)
    end

    it "returns Hash with non-nil key-value pairs" do
      _(options.to_hash).must_equal(every: :day)
    end
  end

  describe "#fetch" do
    it "returns key if present" do
      options[:every] = :month

      _(options.fetch(:every)).must_equal :month
    end

    it "returns default if given" do
      _(options.fetch(:every, :foo)).must_equal :foo
    end

    it "return nil if given as default" do
      _(options.fetch(:every, nil)).must_be_nil
    end

    it "calls block if not found" do
      _(options.fetch(:every, :foo)).must_equal :foo
    end

    it "raises for no block given and value not found" do
      _(-> { options.fetch(:every) }).must_raise(KeyError)
    end

    it "raises for more than two args" do
      _(-> { options.fetch(:every, nil, nil) }).must_raise(ArgumentError)
    end
  end

  describe "#inspect" do
    let(:now) { time_now }

    before do
      options[:every] = :month
      options[:starts] = now
      options[:interval] = 1
    end

    it { _(options.inspect).must_equal "#<Montrose::Options {:every=>:month, :starts=>#{now.inspect}, :interval=>1}>" }
  end
end
