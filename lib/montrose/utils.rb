module Montrose
  module Utils
    module_function

    def month_number(name)
      case name
      when Symbol, String
        Recurrence::MONTHS.index(name.to_s.titleize) or raise "Did not recognize"
      when 1..12
        name
      else
        raise "Did not recognize month #{name}"
      end
    end

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

    # Get the days in the month for +time
    def days_in_month(time)
      date = Date.new(time.year, time.month, 1)
      ((date >> 1) - date).to_i
    end

    # Get the days in the month for +time
    def days_in_year(time)
      date = time.to_date
      ((date + 1.year) - date).to_i
    end
  end
end
