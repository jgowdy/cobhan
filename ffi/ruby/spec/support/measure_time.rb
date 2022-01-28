def measure_time
  start = Time.now
  yield
  finish = Time.now
  finish - start
end
