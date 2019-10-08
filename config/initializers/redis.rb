if !Rails.env.test?
  REDIS = Redis.new(url: ArchiveConfig.redis[:url], db: 1)
else
  REDIS = Redis.new(url: ArchiveConfig.redis[:url], db: 2)
end
