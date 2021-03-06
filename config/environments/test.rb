Rails.application.configure do
  config.active_job.queue_adapter = :test
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr
  config.action_view.raise_on_missing_translations = true

  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: Figaro.env.domain_name }
  config.action_mailer.asset_host = Figaro.env.mailer_domain_name
  config.action_mailer.default_options = { from: Figaro.env.email_from }

  if ENV.key?('RAILS_ASSET_HOST')
    config.action_controller.asset_host = ENV['RAILS_ASSET_HOST']
  end

  config.assets.debug = true
  config.assets.digest = true
  config.middleware.use RackSessionAccess::Middleware
  config.lograge.enabled = true
  config.lograge.custom_options = ->(event) { event.payload }

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
  end

  config.active_support.test_order = :random
end
