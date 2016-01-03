module Montrose
  module Rule
    class MonthOfYear
      include Montrose::Rule

      def initialize(months)
        @months = [*months].compact.map { |m| month_number(m) }
      end

      def include?(time)
        @months.include?(time.month)
      end

      private

      def month_number(name)
        case name
        when Fixnum
          name
        when Symbol, String
          Recurrence::MONTHS.index(name.to_s.titleize)
        else
          raise "Did not recognize month #{name}"
        end
      end
    end
  end
end
