# frozen_string_literal: true

module Montrose
  class ICal
    # DTSTART;TZID=US-Eastern:19970902T090000
    # RRULE:FREQ=DAILY;INTERVAL=2
    def self.parse(ical)
      new(ical).parse
    end

    def initialize(ical)
      @ical = ical
    end

    def parse
      time_zone = extract_time_zone(@ical)

      Time.use_zone(time_zone) do
        Hash[*parse_properties(@ical)]
      end
    end

    private

    def extract_time_zone(ical_string)
      _label, time_string = ical_string.split("\n").grep(/^DTSTART/).join.split(";")
      time_zone_rule, _ = time_string.split(":")
      _label, time_zone = (time_zone_rule || "").split("=")
      time_zone
    end

    # First pass parsing to normalize arbitrary line breaks
    def property_lines(ical_string)
      ical_string.split("\n").each_with_object([]) do |line, lines|
        case line
        when /^(DTSTART|DTEND|EXDATE|RDATE|RRULE)/
          lines << line
        else
          (lines.last || lines << "")
          lines.last << line
        end
      end
    end

    def parse_properties(ical_string)
      property_lines(ical_string).flat_map do |line|
        (property, value) = line.split(":")
        (property, tzid) = property.split(";")

        case property
        when "DTSTART"
          parse_dtstart(tzid, value)
        when "DTEND"
          warn "DTEND not currently supported!"
        when "EXDATE"
          parse_exdate(value)
        when "RDATE"
          warn "RDATE not currently supported!"
        when "RRULE"
          parse_rrule(value)
        end
      end
    end

    def parse_dtstart(tzid, time)
      return [] unless time.present?

      @starts_at = parse_time([tzid, time].compact.join(":"))

      [:starts, @starts_at]
    end

    def parse_timezone(time_string)
       time_zone_rule, _ = time_string.split(":")
       _label, time_zone = (time_zone_rule || "").split("=")
       time_zone
    end

    def parse_time(time_string)
      time_zone = parse_timezone(time_string)
      Montrose::Utils.parse_time(time_string).in_time_zone(time_zone)
    end

    def parse_exdate(exdate)
      return [] unless exdate.present?

      @except = Montrose::Utils.as_date(exdate) # only currently supports dates

      [:except, @except]
    end

    def parse_rrule(rrule)
      rrule.gsub(/\s+/, "").split(";").flat_map do |rule|
        prop, value = rule.split("=")
        case prop
        when "FREQ"
          [:every, Montrose::Frequency.from_term(value)]
        when "INTERVAL"
          [:interval, value.to_i]
        when "COUNT"
          [:total, value.to_i]
        when "UNTIL"
          [:until, parse_time(value)]
        when "BYMINUTE"
          [:minute, Montrose::Minute.parse(value)]
        when "BYHOUR"
          [:hour, Montrose::Hour.parse(value)]
        when "BYMONTH"
          [:month, Montrose::Month.parse(value)]
        when "BYDAY"
          [:day, Montrose::Day.parse(value)]
        when "BYMONTHDAY"
          [:mday, Montrose::MonthDay.parse(value)]
        when "BYYEARDAY"
          [:yday, Montrose::YearDay.parse(value)]
        when "BYWEEKNO"
          [:week, Montrose::Week.parse(value)]
        when "WKST"
          [:week_start, value]
        when "BYSETPOS"
          warn "BYSETPOS not currently supported!"
        else
          raise "Unrecognized rrule '#{rule}'"
        end
      end
    end
  end
end
