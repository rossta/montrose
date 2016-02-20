require "spec_helper"

describe Montrose::Utils do
  include Montrose::Utils

  describe "#month_number" do
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
    it { -> { month_number!(0) }.must_raise Montrose::ConfigurationError }
    it { -> { month_number!(13) }.must_raise Montrose::ConfigurationError }
  end

  describe "#day_number" do
    it { day_number!(:sunday).must_equal 0 }
    it { day_number!(:monday).must_equal 1 }
    it { day_number!(:tuesday).must_equal 2 }
    it { day_number!(:wednesday).must_equal 3 }
    it { day_number!(:thursday).must_equal 4 }
    it { day_number!(:friday).must_equal 5 }
    it { day_number!(:saturday).must_equal 6 }
    it { day_number!(0).must_equal 0 }
    it { day_number!(1).must_equal 1 }
    it { day_number!(2).must_equal 2 }
    it { day_number!(3).must_equal 3 }
    it { day_number!(4).must_equal 4 }
    it { day_number!(5).must_equal 5 }
    it { day_number!(6).must_equal 6 }
    it { -> { day_number!(-3) }.must_raise Montrose::ConfigurationError }
    it { -> { day_number!(:foo) }.must_raise Montrose::ConfigurationError }
  end
end
