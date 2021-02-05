# frozen_string_literal: true

require "spec_helper"

describe Montrose::Month do
  def number!(name)
    Montrose::Month.number!(name)
  end

  describe "#number!" do
    it { _(number!(:january)).must_equal 1 }
    it { _(number!(:february)).must_equal 2 }
    it { _(number!(:march)).must_equal 3 }
    it { _(number!(:april)).must_equal 4 }
    it { _(number!(:may)).must_equal 5 }
    it { _(number!(:june)).must_equal 6 }
    it { _(number!(:july)).must_equal 7 }
    it { _(number!(:august)).must_equal 8 }
    it { _(number!(:september)).must_equal 9 }
    it { _(number!(:october)).must_equal 10 }
    it { _(number!(:november)).must_equal 11 }
    it { _(number!(:december)).must_equal 12 }
    it { _(number!("january")).must_equal 1 }
    it { _(number!("february")).must_equal 2 }
    it { _(number!("march")).must_equal 3 }
    it { _(number!("april")).must_equal 4 }
    it { _(number!("may")).must_equal 5 }
    it { _(number!("june")).must_equal 6 }
    it { _(number!("july")).must_equal 7 }
    it { _(number!("august")).must_equal 8 }
    it { _(number!("september")).must_equal 9 }
    it { _(number!("october")).must_equal 10 }
    it { _(number!("november")).must_equal 11 }
    it { _(number!("december")).must_equal 12 }
    it { _(number!(1)).must_equal 1 }
    it { _(number!(2)).must_equal 2 }
    it { _(number!(3)).must_equal 3 }
    it { _(number!(4)).must_equal 4 }
    it { _(number!(5)).must_equal 5 }
    it { _(number!(6)).must_equal 6 }
    it { _(number!(7)).must_equal 7 }
    it { _(number!(8)).must_equal 8 }
    it { _(number!(9)).must_equal 9 }
    it { _(number!(10)).must_equal 10 }
    it { _(number!(11)).must_equal 11 }
    it { _(number!(12)).must_equal 12 }
    it { _(number!("1")).must_equal 1 }
    it { _(number!("2")).must_equal 2 }
    it { _(number!("3")).must_equal 3 }
    it { _(number!("4")).must_equal 4 }
    it { _(number!("5")).must_equal 5 }
    it { _(number!("6")).must_equal 6 }
    it { _(number!("7")).must_equal 7 }
    it { _(number!("8")).must_equal 8 }
    it { _(number!("9")).must_equal 9 }
    it { _(number!("10")).must_equal 10 }
    it { _(number!("11")).must_equal 11 }
    it { _(number!("12")).must_equal 12 }
    it { _(-> { number!(:foo) }).must_raise Montrose::ConfigurationError }
    it { _(-> { number!("foo") }).must_raise Montrose::ConfigurationError }
    it { _(-> { number!(0) }).must_raise Montrose::ConfigurationError }
    it { _(-> { number!(13) }).must_raise Montrose::ConfigurationError }
  end
end
