# Have Mini Profiler show up on the right
if Rails.env.development?
	Rack::MiniProfiler.config.position = 'right'
end