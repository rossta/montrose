module Montrose
  module Utils
    module_function

    MONTHS = Date::MONTHNAMES
    DAYS = Date::DAYNAMES

    def month_number(name)
      case name
      when Symbol, String
        MONTHS.index(name.to_s.titleize) or raise "Did not recognize"
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
        DAYS.index(name.to_s.titleize)
      when Array
        day_number name.first
      else
        raise "Did not recognize day #{name}"
      end
    end

    def days_in(period, time)
      send("days_in_#{period}", time)
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

    # def nth_day_of_year?(nth_occ, time)
    #   curr_wday = time.wday
    #   nth_day = time.yday
    #   first_wday = time.beginning_of_year.wday
    #   total_days = days_in_year(time)
    #
    #   nth_day_from_start_or_end?(nth_occ, curr_wday, nth_day, first_wday, total_days)
    # end
    #
    # def nth_day_of_month?(nth_occ, time)
    #   curr_wday = time.wday
    #   nth_day = time.mday
    #   first_wday = time.beginning_of_month.wday
    #   total_days = days_in_month(time)
    #
    #   nth_day_from_start_or_end?(nth_occ, curr_wday, nth_day, first_wday, total_days)
    # end
    #
    # def nth_day_from_start_or_end?(nth_occ, curr_wday, nth_day, first_wday, total_days)
    #   first_occ = ((7 - first_wday) + curr_wday) % 7 + 1
    #   total_occ = ((total_days - first_occ + 1) / 7.0).ceil
    #   curr_occ = (curr_wday - first_occ) / 7 + 1
    #
    #   nth_occ == curr_occ || (nth_occ < 0 && (total_occ + nth_occ + 1) == curr_occ)
    # end
  end
end
