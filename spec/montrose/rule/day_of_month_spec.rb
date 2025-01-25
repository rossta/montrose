# frozen_string_literal: true

require "spec_helper"

describe Montrose::Rule::DayOfMonth do
  let(:rule) { Montrose::Rule::DayOfMonth.new(default: [1, 10, -1], overrides: {}, fallback: nil) }
  let(:fallback_rule) { Montrose::Rule::DayOfMonth.new(default: [31], overrides: {}, fallback: -1) }
  let(:override_rule) { Montrose::Rule::DayOfMonth.new(default: [15], overrides: {february: 28, september: 30, november: 30, april: 30}, fallback: nil) }
  let(:fallback_rule_2) { Montrose::Rule::DayOfMonth.new(default: [25], overrides: {}, fallback: -1) }

  describe "#include?" do
    it { assert rule.include?(Time.local(2016, 1, 1)) }
    it { assert rule.include?(Time.local(2016, 1, 10)) }
    it { assert rule.include?(Time.local(2016, 1, 31)) }
    it { assert rule.include?(Time.local(2015, 2, 28)) }
    it { assert rule.include?(Time.local(2016, 2, 29)) }
    it { refute rule.include?(Time.local(2015, 1, 2)) }
    it { refute rule.include?(Time.local(2015, 1, 30)) }
    it { refute rule.include?(Time.local(2015, 2, 27)) }

    it { assert fallback_rule.include?(Time.local(2016, 1, 31)) }
    it { assert fallback_rule.include?(Time.local(2015, 2, 28)) }
    it { assert fallback_rule.include?(Time.local(2016, 2, 29)) }
    it { assert fallback_rule.include?(Time.local(2016, 4, 30)) }
    it { refute fallback_rule.include?(Time.local(2016, 1, 30)) }

    it { assert override_rule.include?(Time.local(2016, 1, 15)) }
    it { assert override_rule.include?(Time.local(2016, 2, 28)) }
    it { assert override_rule.include?(Time.local(2016, 9, 30)) }
    it { assert override_rule.include?(Time.local(2016, 11, 30)) }
    it { assert override_rule.include?(Time.local(2016, 4, 30)) }
    it { refute override_rule.include?(Time.local(2016, 9, 15)) }
    it { refute override_rule.include?(Time.local(2016, 11, 15)) }
    it { refute override_rule.include?(Time.local(2016, 4, 15)) }
    it { refute override_rule.include?(Time.local(2016, 2, 15)) }

    it { refute fallback_rule_2.include?(Time.local(2016, 1, 31)) }
  end

  describe "#continue?" do
    it { assert rule.continue?(time_now) }
  end
end
