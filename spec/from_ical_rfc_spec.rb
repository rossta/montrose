require "spec_helper"

describe "Parsing ICAL RRULE examples from RFC 5545" do
  let(:starts_on) { Time.parse("Sep 2 09:00:00 EDT 1997") }

  it "daily for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;COUNT=10"
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    _(recurrence.events.to_a).must_equal([
      "Sep  2 09:00:00 EDT 1997",
      "Sep  3 09:00:00 EDT 1997",
      "Sep  4 09:00:00 EDT 1997",
      "Sep  5 09:00:00 EDT 1997",
      "Sep  6 09:00:00 EDT 1997",
      "Sep  7 09:00:00 EDT 1997",
      "Sep  8 09:00:00 EDT 1997",
      "Sep  9 09:00:00 EDT 1997",
      "Sep 10 09:00:00 EDT 1997",
      "Sep 11 09:00:00 EDT 1997"
    ].map { |t| Time.parse(t) })
  end

  it "daily until December 24, 1997" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;UNTIL=19971224T000000Z
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    ends_on = Time.parse("Dec 24 00:00:00 EDT 1997")
    days = starts_on.to_date.upto(ends_on.to_date).count - 1
    expected_events = consecutive_days(days, starts: starts_on).take(days)
    # ==> (1997 9:00 AM EDT) September 2-30;October 1-25
    # (1997 9:00 AM EST) October 26-31;November 1-30;December 1-23

    _(recurrence).must_pair_with expected_events
    _(recurrence.events.to_a.size).must_equal days
  end

  it "every other day forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;INTERVAL=2
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = [
      "1997-09-02 09:00:00 -0400",
      "1997-09-04 09:00:00 -0400",
      "1997-09-06 09:00:00 -0400",
      "1997-09-08 09:00:00 -0400",
      "1997-09-10 09:00:00 -0400"
    ].map { |t| Time.parse(t) }
    # ==> (1997 9:00 AM EDT) September 2,4,6,8..

    _(recurrence.take(5)).must_pair_with expected_events
  end

  it "every 10 days, 5 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = [
      "1997-09-02 09:00:00 -0400",
      "1997-09-12 09:00:00 -0400",
      "1997-09-22 09:00:00 -0400",
      "1997-10-02 09:00:00 -0400",
      "1997-10-12 09:00:00 -0400"
    ].map { |t| Time.parse(t) }
    # ==> (1997 9:00 AM EDT) September 2,12,22;
    # October 2,12

    _(recurrence).must_pair_with expected_events
  end

  it "every day in January, for 3 years, by frequency" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19980101T090000
      RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;
      BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = 1998.upto(2000)
      .flat_map { |yyyy|
      1.upto(31).map { |dd|
        Time.parse("Jan #{dd} 09:00:00 EST #{yyyy}")
      }
    }

    _(recurrence).must_pair_with expected_events
  end

  it "every day in January, for 3 years, by day" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19980101T090000
      RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = 1998.upto(2000)
      .flat_map { |yyyy|
      1.upto(31).map { |dd|
        Time.parse("Jan #{dd} 09:00:00 EST #{yyyy}")
      }
    }
    # ==> (1998 9:00 AM EST)January 1-31
    # (1999 9:00 AM EST)January 1-31
    # (2000 9:00 AM EST)January 1-31

    _(recurrence).must_pair_with expected_events
  end

  it "weekly for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;COUNT=10
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = consecutive_days(10, starts: starts_on, interval: 7)

    # ==> (1997 9:00 AM EDT) September 2,9,16,23,30;October 7,14,21
    # (1997 9:00 AM EST) October 28;November 4
    _(recurrence).must_pair_with expected_events
  end
end
