# frozen_string_literal: true

require "montrose/frequency"

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
      Hash[*@ical.each_line.flat_map { |line| parse_line(line) }]
    end

    private

    def parse_line(line)
      line = line.strip
      case line
      when %r{^DTSTART}
        parse_dtstart(line)
      when %r{^RRULE}
        parse_rrule(line)
      end
    end

    def parse_dtstart(line)
      _label, time_string = line.split(";")

      [:starts, Montrose::Utils.parse_time(time_string)]
    end

    def parse_rrule(line)
      _label, rule_string = line.split(":")
      rule_string.split(";").flat_map do |rule|
        prop, value = rule.split("=")
        case prop
        when "FREQ"
          [:every, Montrose::Frequency.from_term(value)]
        when "INTERVAL"
          [:interval, value.to_i]
        when "COUNT"
          [:total, value.to_i]
        end
      end
    end
  end
end
