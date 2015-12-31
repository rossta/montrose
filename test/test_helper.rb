$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "montrose"

require "minitest/autorun"
require "minitest/pride" # awesome colorful output

require "timecop"

begin
  require "pry"
rescue LoadError
end

Dir[File.expand_path("../../test/support/**/*.rb", __FILE__)].each { |f| require f }

module Minitest
  class Spec
    def new_schedule
      Montrose::Schedule.new
    end

    def new_recurrence(options = {})
      Montrose::Recurrence.new(options)
    end

    def now
      Time.zone.now
    end

    def to_time(obj)
      Time.zone.parse(obj)
    end

    def consecutive_days(count, starts: Time.now, interval: 1)
      [].tap do |e|
        date = starts.to_time
        count.times do
          e << date
          date += interval.day
        end
      end
    end
  end

  module Assertions
    def assert_pairs_with(expected_enum, actual_enum)
      expected_enum.zip(actual_enum).each_with_index do |(expected, actual), i|
        assert_equal expected, actual, "Expected #{expected} to equal #{actual} at position #{i}"
      end
    end
  end
end

Array.infect_an_assertion :assert_pairs_with, :must_pair_with
Enumerator.infect_an_assertion :assert_pairs_with, :must_pair_with
