require "spec_helper"

# https://tools.ietf.org/html/rfc5545#section-3.8.5
describe "Parsing ICAL RRULE examples from RFC 5545 Section 3.8.5" do
  let(:starts_on) { Time.parse("Sep 2 09:00:00 EDT 1997") }

  it "daily for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;COUNT=10"
    ICAL
    # ==> (1997 9:00 AM EDT) September 2-11

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => 2.upto(11)}
    )

    _(recurrence).must_pair_with expected_events
  end

  it "daily until December 24, 1997" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;UNTIL=19971224T000000Z
    ICAL
    # ==> (1997 9:00 AM EDT) September 2-30;October 1-25
    # (1997 9:00 AM EST) October 26-31;November 1-30;December 1-23

    recurrence = Montrose::Recurrence.from_ical(ical)

    ends_on = Time.parse("Dec 24 00:00:00 EDT 1997")
    days = starts_on.to_date.upto(ends_on.to_date).count - 1
    expected_events = consecutive_days(days, starts: starts_on).take(days)

    _(recurrence).must_pair_with expected_events
    _(recurrence.events.to_a.size).must_equal days
  end

  it "every other day forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;INTERVAL=2
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,4,6,8,10..

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 4, 6, 8, 10]}
    )

    _(recurrence.take(5)).must_pair_with expected_events
  end

  it "every 10 days, 5 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,12,22;
    # October 2,12

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 12, 22],
                             "Oct" => [2, 12]}
    )

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
    # ==> (1998 9:00 AM EST)January 1-31
    # (1999 9:00 AM EST)January 1-31
    # (2000 9:00 AM EST)January 1-31

    recurrence = Montrose::Recurrence.from_ical(ical)

    expected_events = 1998.upto(2000)
      .flat_map { |yyyy|
      1.upto(31).map { |dd|
        Time.parse("Jan #{dd} 09:00:00 EST #{yyyy}")
      }
    }

    _(recurrence).must_pair_with expected_events
  end

  it "weekly for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;COUNT=10
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,9,16,23,30;October 7,14,21
    # (1997 9:00 AM EST) October 28;November 4

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = consecutive_days(10, starts: starts_on, interval: 7)

    _(recurrence).must_pair_with expected_events
  end

  it "weekly until December 24, 1997" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,9,16,23,30;
    #                        October 7,14,21
    #     (1997 9:00 AM EST) October 28;
    #                        November 4,11,18,25;
    #                        December 2,9,16,23"

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 9, 16, 23, 30],
                             "Oct" => [7, 14, 21]},
      "1997 9:00 AM EST" => {"Oct" => [28],
                             "Nov" => [4, 11, 18, 25],
                             "Dec" => [2, 9, 16, 23]}
    )

    _(recurrence).must_pair_with expected_events
  end

  it "every other week - forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,16,30;
    #                        October 14
    #     (1997 9:00 AM EST) October 28...

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 16, 30],
                             "Oct" => [14]},
      "1997 9:00 AM EST" => {"Oct" => [28]}
    )

    _(recurrence.take(5)).must_pair_with expected_events
  end

  it "weekly on Tuesday and Thursday for five weeks" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,4,9,11,16,18,23,25,30;
    #                       October 2

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 4, 9, 11, 16, 18, 23, 25, 30],
                             "Oct" => [2]}
    )

    _(recurrence).must_pair_with expected_events
  end

  it "weekly on Tuesday and Thursday for five weeks" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,4,9,11,16,18,23,25,30;
    #                       October 2

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 4, 9, 11, 16, 18, 23, 25, 30],
                             "Oct" => [2]}
    )

    _(recurrence).must_pair_with expected_events
  end

  it 'Every other week on Monday, Wednesday, and Friday until December
  24, 1997, starting on Monday, September 1, 1997' do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970901T090000
      RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;
      BYDAY=MO,WE,FR
    ICAL
    # ==> (1997 9:00 AM EDT) September 1,3,5,15,17,19,29;
    #                       October 1,3,13,15,17
    #     (1997 9:00 AM EST) October 27,29,31;
    #                       November 10,12,14,24,26,28;

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [1, 3, 5, 15, 17, 19, 29],
                             "Oct" => [1, 3, 13, 15, 17]},
      "1997 9:00 AM EST" => {"Oct" => [27, 29, 31],
                             "Nov" => [10, 12, 14, 24, 26, 28]}
    )

    _(recurrence).must_pair_with expected_events
  end

  def parse_expected_events(event_map)
    event_map.flat_map { |yyyyz, ms|
      ms.flat_map { |mm, ds|
        ds.map { |dd| Time.parse "#{mm}, #{dd} #{yyyyz}" }
      }
    }
  end
end