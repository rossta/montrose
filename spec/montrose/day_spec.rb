require "spec_helper"

describe Montrose::Day do
  def parse(arg)
    Montrose::Day.parse(arg)
  end

  def number!(name)
    Montrose::Day.number!(name)
  end

  describe "#parse" do
    it { _(parse(:friday)).must_equal([5]) }
    it { _(parse(:friday)).must_equal([5]) }
    it { _(parse([:friday])).must_equal([5]) }
    it { _(parse('friday')).must_equal([5]) }
    it { _(parse(%w[thursday friday])).must_equal([4, 5]) }
    it { _(parse(%w[Thursday Friday])).must_equal([4, 5]) }

    it { _(parse(:fri)).must_equal([5]) }
    it { _(parse(:fri)).must_equal([5]) }
    it { _(parse([:fri])).must_equal([5]) }
    it { _(parse('fri')).must_equal([5]) }
    it { _(parse(%w[thu fri])).must_equal([4, 5]) }
    it { _(parse(%w[Thu Fri])).must_equal([4, 5]) }

    it { _(parse(friday: 1)).must_equal(5 => [1]) }
    it { _(parse(friday: [1])).must_equal(5 => [1]) }
    it { _(parse(5 => [1])).must_equal(5 => [1]) }

    it { _(parse(friday: [1, -1])).must_equal(5 => [1, -1]) }
    it { _(parse(5 => [1, -1])).must_equal(5 => [1, -1]) }

    it { _(parse("FR")).must_equal([5]) }
    it { _(parse("1FR")).must_equal(5 => [1]) }
    it { _(parse("1FR,-1FR")).must_equal(5 => [1, -1]) }
    it { _(parse(%w[1FR -1FR])).must_equal(5 => [1, -1]) }
  end

  describe "#number!" do
    it { _(number!(:sunday)).must_equal 0 }
    it { _(number!(:monday)).must_equal 1 }
    it { _(number!(:tuesday)).must_equal 2 }
    it { _(number!(:wednesday)).must_equal 3 }
    it { _(number!(:thursday)).must_equal 4 }
    it { _(number!(:friday)).must_equal 5 }
    it { _(number!(:saturday)).must_equal 6 }
    it { _(number!("sunday")).must_equal 0 }
    it { _(number!("monday")).must_equal 1 }
    it { _(number!("tuesday")).must_equal 2 }
    it { _(number!("wednesday")).must_equal 3 }
    it { _(number!("thursday")).must_equal 4 }
    it { _(number!("friday")).must_equal 5 }
    it { _(number!("saturday")).must_equal 6 }
    it { _(number!(0)).must_equal 0 }
    it { _(number!(1)).must_equal 1 }
    it { _(number!(2)).must_equal 2 }
    it { _(number!(3)).must_equal 3 }
    it { _(number!(4)).must_equal 4 }
    it { _(number!(5)).must_equal 5 }
    it { _(number!(6)).must_equal 6 }
    it { _(number!("0")).must_equal 0 }
    it { _(number!("1")).must_equal 1 }
    it { _(number!("2")).must_equal 2 }
    it { _(number!("3")).must_equal 3 }
    it { _(number!("4")).must_equal 4 }
    it { _(number!("5")).must_equal 5 }
    it { _(number!("6")).must_equal 6 }
    it { _(-> { number!(-3) }).must_raise Montrose::ConfigurationError }
    it { _(-> { number!(:foo) }).must_raise Montrose::ConfigurationError }
    it { _(-> { number!("foo") }).must_raise Montrose::ConfigurationError }
  end
end
