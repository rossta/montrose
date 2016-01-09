module Montrose
  class Frequency
    class Hourly < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.hour)
      end
    end
  end
end
