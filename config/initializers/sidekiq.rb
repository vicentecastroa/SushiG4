Sidekiq.configure_server do |config|

	config.redis = { network_timeout: 8, url: 'redis://localhost:6379/0' }
	# config.redis = { url: 'redis://localhost:7372/0' }
	schedule_file = "config/schedule.yml"
	if File.exists?(schedule_file)
		Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
	end
	# config.on(:startup) do
	#   SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	# end
end

Sidekiq.configure_client do |config|
	config.redis = { url: 'redis://localhost:6379/0' }
	# config.redis = { url: 'redis://localhost:7372/0' }
end