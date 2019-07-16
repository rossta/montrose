# frozen_string_literal: true

module Montrose
  module Rule
    class After
      include Montrose::Rule

      def self.apply_options(opts)
        opts.start_time
      end

      # Initializes rule
      #
      # @param [Time] start_time - lower bound timestamp
      #
      def initialize(start_time)
        @start_time = start_time
      end

      def include?(time)
        time >= @start_time
      end

      def continue?(_time)
        false
      end
    end
  end
end
