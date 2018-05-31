# frozen_string_literal: true

module Montrose
  class Frequency
    class Daily < Frequency
      def include?(time)
        matches_interval? time.to_date - @starts.to_date
      end

      def to_cron
        "#{@starts.min} #{@starts.hour} #{interval_str} * *"
      end
    end
  end
end
