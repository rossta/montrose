if ENV['TRACE']
  $stack_size = ENV['TRACE'].to_i
  $trace_out = open('trace.txt', 'w')

  set_trace_func proc { |event, file, line, id, binding, classname|
    if event == 'call' && caller.length > $stack_size
      $trace_out.puts "#{file}:#{line} #{classname}##{id}"
    end
  }
end
