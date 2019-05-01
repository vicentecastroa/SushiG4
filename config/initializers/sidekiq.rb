Sidekiq.configure_server do |config|

	config.redis = { url: 'redis://localhost:6379/0' }
	# config.redis = { url: 'redis://localhost:7372/0' }

	config.on(:startup) do
	  SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end
end


Sidekiq.configure_client do |config|
	config.redis = { url: 'redis://localhost:6379/0' }
	# config.redis = { url: 'redis://localhost:7372/0' }

end

Sidekiq::Extensions.enable_delay!
