$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "montrose"

require "minitest/autorun"
require "minitest/pride" # awesome colorful output

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
  end
end
