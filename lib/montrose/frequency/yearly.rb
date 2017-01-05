# frozen_string_literal: true
module Montrose
  class Frequency
    class Yearly < Frequency
      def include?(time)
        matches_interval? time.year - @starts.year
      end
    end
  end
end
