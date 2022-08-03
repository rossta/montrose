# frozen_string_literal: true

require "montrose/errors"

module Montrose
  class Clock
    def initialize(opts = {})
      @options = Montrose::Options.merge(opts)
      @time = nil
      @every = @options.fetch(:every) { fail ConfigurationError, "Required option :every not provided" }
      @interval = @options.fetch(:interval)
      @start_time = @options.fetch(:start_time)
      @at = @options.fetch(:at, []).sort
    end

    # Advances time to new unit by increment and sets
    # new time as "current" time for next tick
    #
    def tick
      @time = next_time(true)
    end

    def peek
      next_time(false)
    end

    private

    def next_time(tick)
      return @start_time if @time.nil?

      if @at.present?
        next_time_at(@time, tick)
      else
        advance_step(@time)
      end
    end

    def advance_step(time)
      time.advance(step)
    end

    def step
      (@step ||= smallest_step) || fail(ConfigurationError, "No step for #{@options.inspect}")
    end

    def smallest_step
      unit_step(:second) ||
        unit_step(:minute) ||
        unit_step(:hour) ||
        unit_step(:day, :mday, :yday) ||
        unit_step(:week) ||
        unit_step(:month) ||
        unit_step(:year)
    end

    # @private
    #
    # Returns next time using :at option. Tries to calculate
    # a time for the current date by incrementing the index
    # of the :at option. Once all items have been exhausted
    # the minimum time is generated for the current date and
    # we advance to the next date based on interval
    #
    def next_time_at(time, tick)
      if current_at_index && (next_time = time_at(time, current_at_index + 1))
        @current_at_index += 1 if tick

        next_time
      else
        min_time = time_at(time, 0)
        @current_at_index = 0 if tick

        advance_step(min_time)
      end
    end

    # @private
    #
    # Returns time with hour, minute and second from :at option
    # at specified index
    #
    def time_at(time, index)
      parts = @at[index]

      return unless parts

      hour, min, sec = parts
      time.change(hour: hour, min: min, sec: sec || 0)
    end

    # @private
    #
    # Keep track of which index we are currently at for :at option.
    #
    def current_at_index
      @current_at_index ||= @at.index do |hour, min, sec = 0|
        @start_time.hour == hour && @start_time.min == min && @start_time.sec == sec
      end
    end

    # @private
    #
    # Returns hash representing unit and amount to advance time
    # when options contain given unit as a key or as a value of
    # the key :every in options
    #
    # options = { every: :day, hour: 8.12 }
    # unit_step(:minute)
    # => nil
    # unit_step(:hour)
    # => { hour: 1 }
    #
    # options = { every: :hour, interval: 6 }
    # unit_step(:minute)
    # => nil
    # unit_step(:hour)
    # => { hour: 6 }
    #
    def unit_step(unit, *alternates)
      is_frequency = @every == unit
      if ([unit] + alternates).any? { |u| @options.key?(u) } && !is_frequency
        # smallest unit, increment by 1
        {step_key(unit) => 1}
      elsif is_frequency
        {step_key(unit) => @interval}
      end
    end

    # @private
    #
    # Change 'unit' to :units
    #
    def step_key(unit)
      "#{unit}s".to_sym
    end
  end
end
