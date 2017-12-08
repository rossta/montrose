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
      @at = @options.fetch(:at, nil)
    end

    # Advances time to new unit by increment and sets
    # new time as "current" time for next tick
    #
    def tick
      @time = peek
    end

    def peek
      return @start_time if @time.nil?

      if @at
        times = @at.map { |(hour, min)| @time.change(hour: hour, min: min) }

        min_next = times.select { |t| t > @time }.min and return min_next

        advance_step(times.min || @time)
      else
        advance_step(@time)
      end
    end

    private

    def advance_step(time)
      time.advance(step)
    end

    def step
      @step ||= smallest_step or fail ConfigurationError, "No step for #{@options.inspect}"
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
        { step_key(unit) => 1 }
      elsif is_frequency
        { step_key(unit) => @interval }
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
