require "spec_helper"

describe "Parsing ICAL RRULE examples from RFC 5545" do
  let(:now) { Time.parse("Tue Sep  2 09:00:00 EDT 1997") } # Tuesday

  before do
    Timecop.freeze(now)
  end

  it "daily for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;COUNT=10"
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    _(recurrence.events.to_a).must_equal([
      Time.parse("Tue Sep  2 09:00:00 EDT 1997"),
      Time.parse("Wed Sep  3 09:00:00 EDT 1997"),
      Time.parse("Thu Sep  4 09:00:00 EDT 1997"),
      Time.parse("Fri Sep  5 09:00:00 EDT 1997"),
      Time.parse("Sat Sep  6 09:00:00 EDT 1997"),
      Time.parse("Sun Sep  7 09:00:00 EDT 1997"),
      Time.parse("Mon Sep  8 09:00:00 EDT 1997"),
      Time.parse("Tue Sep  9 09:00:00 EDT 1997"),
      Time.parse("Wed Sep 10 09:00:00 EDT 1997"),
      Time.parse("Thu Sep 11 09:00:00 EDT 1997")
    ])
  end

  it "daily until December 24, 1997" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;UNTIL=19971224T000000Z
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    starts_on = now.to_date
    ends_on = Time.parse("19971224T000000Z").to_date
    days = starts_on.upto(ends_on).count - 1
    expected_events = consecutive_days(days, starts: now).take(days)

    events = recurrence.events.to_a
    _(events).must_equal expected_events
    _(events.size).must_equal days
  end

  it "every other day forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;INTERVAL=2
    ICAL

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = consecutive_days(5, interval: 2)
    events = recurrence.events.take(5)

    _(events).must_pair_with expected_events
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

    _(recurrence.events).must_pair_with expected_events
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

    _(recurrence.events).must_pair_with expected_events
  end
end
