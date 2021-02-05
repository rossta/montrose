require "spec_helper"

describe Montrose::Day do
  def number!(name)
    Montrose::Day.number!(name)
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
