if !Rails.env.test?
  REDIS = Redis.new(db: 1)
else
  REDIS = Redis.new(db: 2)
end
