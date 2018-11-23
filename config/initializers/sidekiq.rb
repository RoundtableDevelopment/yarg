# Using a separate shared redis database here than the cache
# store uses for a small bit of isolation.  This won't have any
# performance benefits but it may be a little bit easier to
# copy one of those to a separate redis instance if it's necessary
# in the future.
Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/1" }
end

Sidekiq.configure_client do |config|
  config.redis = { size: 3, url: "#{ENV['REDIS_URL']}/1" }
end
