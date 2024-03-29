# frozen_string_literal: true

class SoftValidator::Railtie < Rails::Railtie
  initializer("soft_validator.initialize") do
    SoftValidator::LogSubscriber.attach
    SoftValidator.enforced = (Rails.env.development? || Rails.env.test?)
  end
end
