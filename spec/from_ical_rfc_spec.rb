require "spec_helper"

# https://tools.ietf.org/html/rfc5545#section-3.8.5
describe "Parsing ICAL RRULE examples from RFC 5545 Section 3.8.5" do
  def parse_expected_events(event_map)
    event_map.flat_map { |yyyyz, ms|
      ms.flat_map { |mm, ds|
        ds.map { |dd| Time.parse "#{mm}, #{dd} #{yyyyz}" }
      }
    }
  end

  def parse_expect_by_time_of_day(event_map)
    event_map.flat_map { |date, times|
      times.map { |time| Time.parse "#{date} #{time} EDT" }
    }
  end


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

  it "every other week on Tuesday and Thursday, for 8 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH
    ICAL
    # ==> (1997 9:00 AM EDT) September 2,4,16,18,30;
    #                        October 2,14,16

    recurrence = Montrose::Recurrence.from_ical(ical)
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 4, 16, 18, 30],
                             "Oct" => [2, 14, 16]}
    )

    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the first Friday for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970905T090000
      RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR
    ICAL
    # ==> (1997 9:00 AM EDT) September 5;October 3
    #     (1997 9:00 AM EST) November 7;December 5
    #     (1998 9:00 AM EST) January 2;February 6;March 6;April 3
    #     (1998 9:00 AM EDT) May 1;June 5
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [5],
                             "Oct" => [3]},
      "1997 9:00 AM EST" => {"Nov" => [7],
                             "Dec" => [5]},
      "1998 9:00 AM EST" => {"Jan" => [2],
                             "Feb" => [6],
                             "Mar" => [6],
                             "Apr" => [3]},
      "1998 9:00 AM EDT" => {"May" => [1],
                             "Jun" => [5]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the first Friday until December 24, 1997" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970905T090000
      RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR
    ICAL
    #   ==> (1997 9:00 AM EDT) September 5; October 3
    #       (1997 9:00 AM EST) November 7; December 5
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [5],
                             "Oct" => [3]},
      "1997 9:00 AM EST" => {"Nov" => [7],
                             "Dec" => [5]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every other month on the first and last Sunday of the month for 10
   occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970907T090000
      RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU
    ICAL
    #   ==> (1997 9:00 AM EDT) September 7,28
    #       (1997 9:00 AM EST) November 2,30
    #       (1998 9:00 AM EST) January 4,25;March 1,29
    #       (1998 9:00 AM EDT) May 3,31
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [7, 28]},
      "1997 9:00 AM EST" => {"Nov" => [2, 30]},
      "1998 9:00 AM EST" => {"Jan" => [4, 25],
                             "Mar" => [1, 29]},
      "1998 9:00 AM EDT" => {"May" => [3, 31]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the second-to-last Monday of the month for 6 months" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970922T090000
      RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO
    ICAL
    #   ==> (1997 9:00 AM EDT) September 22;October 20
    #       (1997 9:00 AM EST) November 17;December 22
    #       (1998 9:00 AM EST) January 19;February 16
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [22],
                             "Oct" => [20]},
      "1997 9:00 AM EST" => {"Nov" => [17],
                             "Dec" => [22]},
      "1998 9:00 AM EST" => {"Jan" => [19],
                             "Feb" => [16]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the third-to-the-last day of the month, forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970928T090000
      RRULE:FREQ=MONTHLY;BYMONTHDAY=-3
    ICAL
    #   ==> (1997 9:00 AM EDT) September 28
    #       (1997 9:00 AM EST) October 29;November 28;December 29
    #       (1998 9:00 AM EST) January 29;February 26
    #       ...
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [28]},
      "1997 9:00 AM EST" => {"Oct" => [29],
                             "Nov" => [28],
                             "Dec" => [29]},
      "1998 9:00 AM EST" => {"Jan" => [29],
                             "Feb" => [26]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the 2nd and 15th of the month for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15
    ICAL
    #   ==> (1997 9:00 AM EDT) September 2,15;October 2,15
    #       (1997 9:00 AM EST) November 2,15;December 2,15
    #       (1998 9:00 AM EST) January 2,15
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 15],
                             "Oct" => [2, 15]},
      "1997 9:00 AM EST" => {"Nov" => [2, 15],
                             "Dec" => [2, 15]},
      "1998 9:00 AM EST" => {"Jan" => [2, 15]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "monthly on the first and last day of the month for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970930T090000
      RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1
    ICAL
    #   ==> (1997 9:00 AM EDT) September 30;October 1
    #       (1997 9:00 AM EST) October 31;November 1,30;December 1,31
    #       (1998 9:00 AM EST) January 1,31;February 1
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [30],
                             "Oct" => [1]},
      "1997 9:00 AM EST" => {"Oct" => [31],
                             "Nov" => [1, 30],
                             "Dec" => [1, 31]},
      "1998 9:00 AM EST" => {"Jan" => [1, 31],
                             "Feb" => [1]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every 18 months on the 10th thru 15th of the month for 10
  occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970910T090000
      RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,
      13,14,15
    ICAL
    #   ==> (1997 9:00 AM EDT) September 10,11,12,13,14,15
    #       (1999 9:00 AM EST) March 10,11,12,13
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [10, 11, 12, 13, 14, 15]},
      "1999 9:00 AM EST" => {"Mar" => [10, 11, 12, 13]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every Tuesday, every other month" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU
    ICAL
    #   ==> (1997 9:00 AM EDT) September 2,9,16,23,30
    #       (1997 9:00 AM EST) November 4,11,18,25
    #       (1998 9:00 AM EST) January 6,13,20,27;March 3,10,17,24,31
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [2, 9, 16, 23, 30]},
      "1997 9:00 AM EST" => {"Nov" => [4, 11, 18, 25]},
      "1998 9:00 AM EST" => {"Jan" => [6, 13, 20, 27],
                             "Mar" => [3, 10, 17, 24, 31]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "yearly in June and July for 10 occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970610T090000
      RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7
    ICAL
    #   ==> (1997 9:00 AM EDT) June 10;July 10
    #       (1998 9:00 AM EDT) June 10;July 10
    #       (1999 9:00 AM EDT) June 10;July 10
    #       (2000 9:00 AM EDT) June 10;July 10
    #       (2001 9:00 AM EDT) June 10;July 10
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Jun" => [10],
                             "Jul" => [10]},
      "1998 9:00 AM EDT" => {"Jun" => [10],
                             "Jul" => [10]},
      "1999 9:00 AM EDT" => {"Jun" => [10],
                             "Jul" => [10]},
      "2000 9:00 AM EDT" => {"Jun" => [10],
                             "Jul" => [10]},
      "2001 9:00 AM EDT" => {"Jun" => [10],
                             "Jul" => [10]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "Every other year on January, February, and March for 10
  occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970310T090000
      RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3
    ICAL
    #   ==> (1997 9:00 AM EST) March 10
    #       (1999 9:00 AM EST) January 10;February 10;March 10
    #       (2001 9:00 AM EST) January 10;February 10;March 10
    #       (2003 9:00 AM EST) January 10;February 10;March 10
    expected_events = parse_expected_events(
      "1997 9:00 AM EST" => {"Mar" => [10]},
      "1999 9:00 AM EST" => {"Jan" => [10],
                             "Feb" => [10],
                             "Mar" => [10]},
      "2001 9:00 AM EST" => {"Jan" => [10],
                             "Feb" => [10],
                             "Mar" => [10]},
      "2003 9:00 AM EST" => {"Jan" => [10],
                             "Feb" => [10],
                             "Mar" => [10]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every third year on the 1st, 100th, and 200th day for 10
  occurrences" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970101T090000
      RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200
    ICAL
    #   ==> (1997 9:00 AM EST) January 1
    #       (1997 9:00 AM EDT) April 10;July 19
    #       (2000 9:00 AM EST) January 1
    #       (2000 9:00 AM EDT) April 9;July 18
    #       (2003 9:00 AM EST) January 1
    #       (2003 9:00 AM EDT) April 10;July 19
    #       (2006 9:00 AM EST) January 1
    expected_events = parse_expected_events(
      "1997 9:00 AM EST" => {"Jan" => [1]},
      "1997 9:00 AM EDT" => {"Apr" => [10],
                             "Jul" => [19]},
      "2000 9:00 AM EST" => {"Jan" => [1]},
      "2000 9:00 AM EDT" => {"Apr" => [9],
                             "Jul" => [18]},
      "2003 9:00 AM EST" => {"Jan" => [1]},
      "2003 9:00 AM EDT" => {"Apr" => [10],
                             "Jul" => [19]},
      "2006 9:00 AM EST" => {"Jan" => [1]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every 20th Monday of the year, forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970519T090000
      RRULE:FREQ=YEARLY;BYDAY=20MO
    ICAL
    #   ==> (1997 9:00 AM EDT) May 19
    #       (1998 9:00 AM EDT) May 18
    #       (1999 9:00 AM EDT) May 17
    #       ...
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"May" => [19]},
      "1998 9:00 AM EDT" => {"May" => [18]},
      "1999 9:00 AM EDT" => {"May" => [17]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "Monday of week number 20 (where the default start of the week is
  Monday), forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970512T090000
      RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO
    ICAL
    #   ==> (1997 9:00 AM EDT) May 12
    #       (1998 9:00 AM EDT) May 11
    #       (1999 9:00 AM EDT) May 17
    #       ...

    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"May" => [12]},
      "1998 9:00 AM EDT" => {"May" => [11]},
      "1999 9:00 AM EDT" => {"May" => [17]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every Thursday in March, forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970313T090000
      RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH
    ICAL
    #   ==> (1997 9:00 AM EST) March 13,20,27
    #       (1998 9:00 AM EST) March 5,12,19,26
    #       (1999 9:00 AM EST) March 4,11,18,25
    #       ...
    expected_events = parse_expected_events(
      "1997 9:00 AM EST" => {"Mar" => [13, 20, 27]},
      "1998 9:00 AM EST" => {"Mar" => [5, 12, 19, 26]},
      "1999 9:00 AM EST" => {"Mar" => [4, 11, 18, 25]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every Thursday, but only during June, July, and August, forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970605T090000
      RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8
    ICAL
    #   ==> (1997 9:00 AM EDT) June 5,12,19,26;July 3,10,17,24,31;
    #                          August 7,14,21,28
    #       (1998 9:00 AM EDT) June 4,11,18,25;July 2,9,16,23,30;
    #                          August 6,13,20,27
    #       (1999 9:00 AM EDT) June 3,10,17,24;July 1,8,15,22,29;
    #                          August 5,12,19,26
    #       ...
    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Jun" => [5, 12, 19, 26],
                             "Jul" => [3, 10, 17, 24, 31],
                             "Aug" => [7, 14, 21, 28]},
      "1998 9:00 AM EDT" => {"Jun" => [4, 11, 18, 25],
                             "Jul" => [2, 9, 16, 23, 30],
                             "Aug" => [6, 13, 20, 27]},
      "1999 9:00 AM EDT" => {"Jun" => [3, 10, 17, 24],
                             "Jul" => [1, 8, 15, 22, 29],
                             "Aug" => [5, 12, 19, 26]}
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every Friday the 13th, forever" do
    ical = <<~ICAL
      DTSTART;TZID=America/New_York:19970902T090000
      EXDATE;TZID=America/New_York:19970902T090000
      RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13
    ICAL
    #   ==> (1998 9:00 AM EST) February 13;March 13;November 13
    #       (1999 9:00 AM EDT) August 13
    #       (2000 9:00 AM EDT) October 13
    #       ...

    expected_events = parse_expected_events(
      "1998 9:00 AM EST" => {"Feb" => [13],
                             "Mar" => [13],
                             "Nov" => [13]},
      "1999 9:00 AM EDT" => {"Aug" => [13]},
      "2000 9:00 AM EDT" => {"Oct" => [13]},
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
    _(recurrence.default_options[:except]).must_equal([Date.parse('19970902')])
  end

  it "The first Saturday that follows the first Sunday of the month,
  forever" do
    ical = <<~ical
      DTSTART;TZID=America/New_York:19970913T090000
      RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13
    ical
    #   ==> (1997 9:00 AM EDT) September 13;October 11
    #       (1997 9:00 AM EST) November 8;December 13
    #       (1998 9:00 AM EST) January 10;February 7;March 7
    #       (1998 9:00 AM EDT) April 11;May 9;June 13...
    #       ...

    expected_events = parse_expected_events(
      "1997 9:00 AM EDT" => {"Sep" => [13],
                             "Oct" => [11]},
      "1997 9:00 AM EST" => {"Nov" => [8],
                             "Dec" => [13]},
      "1998 9:00 AM EST" => {"Jan" => [10],
                             "Feb" => [7],
                             "Mar" => [7]},
      "1998 9:00 AM EDT" => {"Apr" => [11],
                             "May" => [9],
                             "Jun" => [13]},
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every 4 years, the first Tuesday after a Monday in November,
    forever (U.S. Presidential Election day)" do
    ical = <<~ical
      DTSTART;TZID=America/New_York:19961105T090000
      RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;
       BYMONTHDAY=2,3,4,5,6,7,8
    ical
    #    ==> (1996 9:00 AM EST) November 5
    #        (2000 9:00 AM EST) November 7
    #        (2004 9:00 AM EST) November 2
    #        ...
    expected_events = parse_expected_events(
      "1996 9:00 AM EST" => {"Nov" => [5]},
      "2000 9:00 AM EST" => {"Nov" => [7]},
      "2004 9:00 AM EST" => {"Nov" => [2]},
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  # TODO support BYSETPOS
  # it "the third instance into the month of one of Tuesday, Wednesday, or
  # Thursday, for the next 3 months" do
  #   ical = <<~ical
  #     DTSTART;TZID=America/New_York:19970904T090000
  #     RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3
  #   ical
  #   #   ==> (1997 9:00 AM EDT) September 4;October 7
  #   #       (1997 9:00 AM EST) November 6
  #   expected_events = parse_expected_events(
  #     "1997 9:00 AM EDT" => {"Sep" => [4],
  #                            "Oct" => [7]},
  #     "1997 9:00 AM EST" => {"Nov" => [6]},
  #   )

  #   recurrence = Montrose::Recurrence.from_ical(ical)
  #   _(recurrence).must_pair_with expected_event
  # end

  #  The second-to-last weekday of the month:

  #   DTSTART;TZID=America/New_York:19970929T090000
  #   RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2

  #   ==> (1997 9:00 AM EDT) September 29
  #       (1997 9:00 AM EST) October 30;November 27;December 30
  #       (1998 9:00 AM EST) January 29;February 26;March 30
  #       ...

  it "every 3 hours from 9:00 AM to 5:00 PM on a specific day" do
    ical = <<~ical
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000
    ical
    #   ==> (September 2, 1997 EDT) 09:00,12:00,15:00
    expected_events = parse_expected_events(
      "1997 09:00 AM EDT" => {"Sept" => [2]},
      "1997 12:00 PM EDT" => {"Sept" => [2]},
      "1997 15:00 PM EDT" => {"Sept" => [2]},
    )
    expected_events = parse_expect_by_time_of_day(
      "Sept 2 1997" => %w[09:00 12:00 15:00]
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  it "every 15 minutes for 6 occurrences" do
    ical = <<~ical
      DTSTART;TZID=America/New_York:19970902T090000
      RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6
    ical

    #   ==> (September 2, 1997 EDT) 09:00,09:15,09:30,09:45,10:00,10:15
    expected_events = parse_expect_by_time_of_day(
      "Sept 2 1997" => %w[09:00 09:15 09:30 09:45 10:00 10:15]
    )

    recurrence = Montrose::Recurrence.from_ical(ical)
    _(recurrence).must_pair_with expected_events
  end

  #  Every hour and a half for 4 occurrences:

  #   DTSTART;TZID=America/New_York:19970902T090000
  #   RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4

  #   ==> (September 2, 1997 EDT) 09:00,10:30;12:00;13:30

  #  Every 20 minutes from 9:00 AM to 4:40 PM every day:

  #   DTSTART;TZID=America/New_York:19970902T090000
  #   RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
  #   or
  #   RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16

  #   ==> (September 2, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
  #                               ... 16:00,16:20,16:40
  #       (September 3, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
  #                               ...16:00,16:20,16:40
  #       ...

  #  An example where the days generated makes a difference because of
  #  WKST:

  #   DTSTART;TZID=America/New_York:19970805T090000
  #   RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO

  #   ==> (1997 EDT) August 5,10,19,24

  #  changing only WKST from MO to SU, yields different results...

  #   DTSTART;TZID=America/New_York:19970805T090000
  #   RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU

  #   ==> (1997 EDT) August 5,17,19,31

  #  An example where an invalid date (i.e., February 30) is ignored.

  #   DTSTART;TZID=America/New_York:20070115T090000
  #   RRULE:FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5

  #   ==> (2007 EST) January 15,30
  #       (2007 EST) February 15
  #       (2007 EDT) March 15,30
end
