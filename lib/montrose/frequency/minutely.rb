module Montrose
  class Frequency
    class Minutely < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.minute)
      end
    end
  end
end
