# frozen_string_literal: true

module Montrose
  class Frequency
    class Secondly < Frequency
      def include?(time)
        matches_interval?((time - @starts) / 1.second)
      end
    end
  end
end
