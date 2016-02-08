require "spec_helper"

describe Montrose do
  it { assert ::Montrose::VERSION }

  describe ".r" do
    it { Montrose.r(every: :day).must_be_kind_of(Montrose::Recurrence) }
    it { Montrose.r(every: :day).default_options[:every].must_equal(:day) }

    it { Montrose.recurrence(every: :day).must_be_kind_of(Montrose::Recurrence) }
    it { Montrose.recurrence(every: :day).default_options[:every].must_equal(:day) }
  end
end
