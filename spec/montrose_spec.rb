# frozen_string_literal: true

require "spec_helper"

describe Montrose do
  it { assert ::Montrose::VERSION }

  describe ".r" do
    it { _(Montrose.r).must_be_kind_of(Montrose::Recurrence) }
    it { _(Montrose.r.default_options.to_h).must_equal({}) }

    it { _(Montrose.r(every: :day)).must_be_kind_of(Montrose::Recurrence) }
    it { _(Montrose.r(every: :day).default_options[:every]).must_equal(:day) }

    it { _(Montrose.recurrence).must_be_kind_of(Montrose::Recurrence) }
    it { _(Montrose.recurrence.default_options.to_h).must_equal({}) }

    it { _(Montrose.recurrence(every: :day)).must_be_kind_of(Montrose::Recurrence) }
    it { _(Montrose.recurrence(every: :day).default_options[:every]).must_equal(:day) }
  end
end
