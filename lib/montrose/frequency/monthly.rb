module Montrose
  class Frequency
    class Monthly < Frequency
      def include?(time)
        matches_interval?((time.month - @starts.month) + (time.year - @starts.year) * 12)
      end
    end
  end
end
