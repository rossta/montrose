require "spec_helper"

describe Montrose::Utils do
  include Montrose::Utils

  it "return current_time" do
    Time.freeze do
      expect(current_time).to eq(Time.current)
    end
  end

  describe "#parse_time" do
    it { parse_time("Sept 1, 2015 12:00PM").must_equal Time.parse("Sept 1, 2015 12:00PM") }
    it "uses Time.zone if available" do
      Time.use_zone("Hawaii") do
        time = parse_time("Sept 1, 2015 12:00PM")
        time.month.must_equal 9
        time.day.must_equal 1
        time.year.must_equal 2015
        time.hour.must_equal 12
        time.utc_offset.must_equal(-10.hours)
      end
    end
  end

  describe "#month_number!" do
    it { month_number!(:january).must_equal 1 }
    it { month_number!(:february).must_equal 2 }
    it { month_number!(:march).must_equal 3 }
    it { month_number!(:april).must_equal 4 }
    it { month_number!(:may).must_equal 5 }
    it { month_number!(:june).must_equal 6 }
    it { month_number!(:july).must_equal 7 }
    it { month_number!(:august).must_equal 8 }
    it { month_number!(:september).must_equal 9 }
    it { month_number!(:october).must_equal 10 }
    it { month_number!(:november).must_equal 11 }
    it { month_number!(:december).must_equal 12 }
    it { month_number!("january").must_equal 1 }
    it { month_number!("february").must_equal 2 }
    it { month_number!("march").must_equal 3 }
    it { month_number!("april").must_equal 4 }
    it { month_number!("may").must_equal 5 }
    it { month_number!("june").must_equal 6 }
    it { month_number!("july").must_equal 7 }
    it { month_number!("august").must_equal 8 }
    it { month_number!("september").must_equal 9 }
    it { month_number!("october").must_equal 10 }
    it { month_number!("november").must_equal 11 }
    it { month_number!("december").must_equal 12 }
    it { month_number!(1).must_equal 1 }
    it { month_number!(2).must_equal 2 }
    it { month_number!(3).must_equal 3 }
    it { month_number!(4).must_equal 4 }
    it { month_number!(5).must_equal 5 }
    it { month_number!(6).must_equal 6 }
    it { month_number!(7).must_equal 7 }
    it { month_number!(8).must_equal 8 }
    it { month_number!(9).must_equal 9 }
    it { month_number!(10).must_equal 10 }
    it { month_number!(11).must_equal 11 }
    it { month_number!(12).must_equal 12 }
    it { -> { month_number!(:foo) }.must_raise Montrose::ConfigurationError }
    it { -> { month_number!("foo") }.must_raise Montrose::ConfigurationError }
    it { -> { month_number!(0) }.must_raise Montrose::ConfigurationError }
    it { -> { month_number!(13) }.must_raise Montrose::ConfigurationError }
  end

  describe "#day_number!" do
    it { day_number!(:sunday).must_equal 0 }
    it { day_number!(:monday).must_equal 1 }
    it { day_number!(:tuesday).must_equal 2 }
    it { day_number!(:wednesday).must_equal 3 }
    it { day_number!(:thursday).must_equal 4 }
    it { day_number!(:friday).must_equal 5 }
    it { day_number!(:saturday).must_equal 6 }
    it { day_number!("sunday").must_equal 0 }
    it { day_number!("monday").must_equal 1 }
    it { day_number!("tuesday").must_equal 2 }
    it { day_number!("wednesday").must_equal 3 }
    it { day_number!("thursday").must_equal 4 }
    it { day_number!("friday").must_equal 5 }
    it { day_number!("saturday").must_equal 6 }
    it { day_number!(0).must_equal 0 }
    it { day_number!(1).must_equal 1 }
    it { day_number!(2).must_equal 2 }
    it { day_number!(3).must_equal 3 }
    it { day_number!(4).must_equal 4 }
    it { day_number!(5).must_equal 5 }
    it { day_number!(6).must_equal 6 }
    it { -> { day_number!(-3) }.must_raise Montrose::ConfigurationError }
    it { -> { day_number!(:foo) }.must_raise Montrose::ConfigurationError }
    it { -> { day_number!("foo") }.must_raise Montrose::ConfigurationError }
  end

  describe "#days_in_month" do
    non_leap_year = 2015
    leap_year = 2016
    it { days_in_month(1).must_equal 31 }
    it { days_in_month(2, non_leap_year).must_equal 28 }
    it { days_in_month(2, leap_year).must_equal 29 }
    it { days_in_month(3).must_equal 31 }
    it { days_in_month(4).must_equal 30 }
    it { days_in_month(5).must_equal 31 }
    it { days_in_month(6).must_equal 30 }
    it { days_in_month(7).must_equal 31 }
    it { days_in_month(8).must_equal 31 }
    it { days_in_month(9).must_equal 30 }
    it { days_in_month(10).must_equal 31 }
    it { days_in_month(11).must_equal 30 }
    it { days_in_month(12).must_equal 31 }
  end

  describe "#days_in_year" do
    it { days_in_year(2005).must_equal 365 }
    it { days_in_year(2004).must_equal 366 }
    it { days_in_year(2000).must_equal 366 }
    it { days_in_year(1900).must_equal 365 }
  end
end
