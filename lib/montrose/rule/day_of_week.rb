module Montrose
  module Rule
    class DayOfWeek
      include Montrose::Rule

      def initialize(days)
        @days = [*days].compact.map { |d| day_number(d) }
      end

      def include?(time)
        @days.include?(time.wday)
      end

      private

      def day_number(name)
        case name
        when Fixnum
          name
        when Symbol, String
          Recurrence::DAYS.index(name.to_s.titleize)
        when Array
          day_number name.first
        else
          raise "Did not recognize day #{name}"
        end
      end
    end
  end
end
