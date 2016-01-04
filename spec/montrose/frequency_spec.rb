require "spec_helper"

describe Montrose::Frequency do
  let(:time_now) { Time.now }

  before do
    Timecop.freeze(time_now)
  end

  describe "self.from_options" do
    it "every: :year" do
      frequency = Montrose::Frequency.from_options(every: :year)
      frequency.must_be_instance_of Montrose::Frequency::Yearly
    end

    it "every: :week" do
      frequency = Montrose::Frequency.from_options(every: :week)
      frequency.must_be_instance_of Montrose::Frequency::Weekly
    end

    it "every: :month" do
      frequency = Montrose::Frequency.from_options(every: :month)
      frequency.must_be_instance_of Montrose::Frequency::Monthly
    end

    it "every: :day" do
      frequency = Montrose::Frequency.from_options(every: :day)
      frequency.must_be_instance_of Montrose::Frequency::Daily
    end

    it "every: :hour" do
      frequency = Montrose::Frequency.from_options(every: :hour)
      frequency.must_be_instance_of Montrose::Frequency::Hourly
    end

    it "every: :minute" do
      frequency = Montrose::Frequency.from_options(every: :minute)
      frequency.must_be_instance_of Montrose::Frequency::Minutely
    end

    it "every: 'minute' as string value" do
      frequency = Montrose::Frequency.from_options(every: "minute")
      frequency.must_be_instance_of Montrose::Frequency::Minutely
    end

    it "every: :other" do
      -> { Montrose::Frequency.from_options(every: :other) }.must_raise
    end

    it "missing every" do
      -> { Montrose::Frequency.from_options({}) }.must_raise
    end
  end

  describe "Minutely" do
    describe "#include?" do
      it "is true when matches default minutely interval" do
        frequency = new_frequency(every: :minute)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.minutes
        assert frequency.include? time_now + 30.minutes
      end

      it "is true when matches given minutely interval" do
        frequency = new_frequency(every: :minute, interval: 30)

        assert frequency.include? time_now
        assert frequency.include? time_now + 30.minutes
        assert frequency.include? time_now + 1.hour
      end

      it "is false when does not match default minutely interval" do
        frequency = new_frequency(every: :minute)

        refute frequency.include? time_now + 1.second
        refute frequency.include? time_now + 2.minutes + 2.seconds
        refute frequency.include? time_now + 30.minutes + 3.seconds
      end

      it "is false when does not match given minutely interval" do
        frequency = new_frequency(every: :minute, interval: 30)

        refute frequency.include? time_now + 1.minutes
        refute frequency.include? time_now + 30.minutes + 2.minutes
        refute frequency.include? time_now + 60.minutes + 3.minutes
      end
    end
  end

  describe "Hourly" do
    describe "#include?" do
      it "is true when matches default hourly interval" do
        frequency = new_frequency(every: :hour)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.hours
        assert frequency.include? time_now + 30.hours
      end

      it "is true when matches given hourly interval" do
        frequency = new_frequency(every: :hour, interval: 5)

        assert frequency.include? time_now
        assert frequency.include? time_now + 5.hours
        assert frequency.include? time_now + 10.hours
      end

      it "is false when does not match default hourly interval" do
        frequency = new_frequency(every: :hour)

        refute frequency.include? time_now + 1.second
        refute frequency.include? time_now + 2.hours + 2.seconds
        refute frequency.include? time_now + 30.hours + 3.minutes
      end

      it "is false when does not match given hourly interval" do
        frequency = new_frequency(every: :hour, interval: 5)

        refute frequency.include? time_now + 1.hours
        refute frequency.include? time_now + 3.hours
        refute frequency.include? time_now + 10.hours + 3.minutes
      end
    end
  end

  describe "Daily" do
    describe "#include?" do
      it "is true when matches default daily interval" do
        frequency = new_frequency(every: :day)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.days
        assert frequency.include? time_now + 30.days
      end

      it "is true when matches given daily interval" do
        frequency = new_frequency(every: :day, interval: 5)

        assert frequency.include? time_now
        assert frequency.include? time_now + 5.days
        assert frequency.include? time_now + 10.days
      end

      it "is false when does not match given daily interval" do
        frequency = new_frequency(every: :day, interval: 5)

        refute frequency.include? time_now + 1.days
        refute frequency.include? time_now + 3.days
      end
    end
  end

  describe "Weekly" do
    describe "#include?" do
      it "is true when matches default weekly interval" do
        frequency = new_frequency(every: :week)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.weeks
        assert frequency.include? time_now + 30.weeks
      end

      it "is true when matches given weekly interval" do
        frequency = new_frequency(every: :week, interval: 5)

        assert frequency.include? time_now
        assert frequency.include? time_now + 5.weeks
        assert frequency.include? time_now + 10.weeks
      end

      it "is false when does not match given weekly interval" do
        frequency = new_frequency(every: :week, interval: 5)

        refute frequency.include? time_now + 1.weeks
        refute frequency.include? time_now + 3.weeks
      end
    end
  end

  describe "Monthly" do
    describe "#include?" do
      it "is true when matches default monthly interval" do
        frequency = new_frequency(every: :month)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.months
        assert frequency.include? time_now + 30.months
      end

      it "is true when matches given monthly interval" do
        frequency = new_frequency(every: :month, interval: 5)

        assert frequency.include? time_now
        assert frequency.include? time_now + 5.months
        assert frequency.include? time_now + 10.months
      end

      it "is false when does not match given monthly interval" do
        frequency = new_frequency(every: :month, interval: 5)

        refute frequency.include? time_now + 1.months
        refute frequency.include? time_now + 3.months
      end
    end
  end

  describe "Yearly" do
    describe "#include?" do
      it "is true when matches default yearly interval" do
        frequency = new_frequency(every: :year)

        assert frequency.include? time_now
        assert frequency.include? time_now + 2.years
        assert frequency.include? time_now + 30.years
      end

      it "is true when matches given yearly interval" do
        frequency = new_frequency(every: :year, interval: 5)

        assert frequency.include? time_now
        assert frequency.include? time_now + 5.years
        assert frequency.include? time_now + 10.years
      end

      it "is false when does not match given yearly interval" do
        frequency = new_frequency(every: :year, interval: 5)

        refute frequency.include? time_now + 1.years
        refute frequency.include? time_now + 3.years
      end
    end
  end
end
