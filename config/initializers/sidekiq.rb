Sidekiq.configure_server do |config|
	config.on(:startup) do
	  SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end
end

Sidekiq::Extensions.enable_delay!
