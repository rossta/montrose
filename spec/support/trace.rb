# frozen_string_literal: true

if ENV["TRACE"]
  stack_size = ENV["TRACE"].to_i
  trace_out = open("trace.txt", "w")

  set_trace_func(proc { |event, file, line, id, _binding, classname|
    trace_out.puts "#{file}:#{line} #{classname}##{id}" if event == "call" && caller.length > stack_size
  })
end
