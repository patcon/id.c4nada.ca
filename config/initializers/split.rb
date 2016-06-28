Split.configure do |config|
  config.db_failover = true
  config.enabled = !Rails.env.test?
  config.experiments = YAML.load_file("#{Rails.root}/config/experiments.yml")
end
