# frozen_string_literal: true

module Montrose
  module Rule
    class Until
      include Montrose::Rule

      def self.apply_options(opts)
        return false unless opts[:until]

        { until: opts[:until], exclude_end: opts.fetch(:exclude_end, false) }
      end

      def initialize(opts)
        @end_time = opts.fetch(:until)
        @exclude_end = opts.fetch(:exclude_end)
      end

      def include?(time)
        if @exclude_end
          time < @end_time
        else
          time <= @end_time
        end
      end

      def continue?(_time)
        false
      end
    end
  end
end
