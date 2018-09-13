uncomment_lines "config/environments/production.rb", /config\.force_ssl = true/

gsub_file "config/environments/production.rb", ":uglifier", "Uglifier.new(harmony: true)"

insert_into_file "config/environments/production.rb",
                 after: /# config\.action_mailer\.raise_deliv.*\n/ do
  <<-RUBY

  config.action_mailer.smtp_settings = {
    user_name: ENV.fetch('SMTP_USERNAME'),
    password: ENV.fetch('SMTP_PASSWORD'),
    address: 'smtp.sendgrid.net',
    domain: ENV.fetch('DEFAULT_URL'),
    port: 587,
    enable_starttls_auto: true
  }

  config.action_mailer.delivery_method       = :smtp
  config.action_mailer.perform_deliveries    = true
  config.action_mailer.raise_delivery_errors = true
  
  RUBY
end


