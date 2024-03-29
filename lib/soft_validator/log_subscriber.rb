# frozen_string_literal: true

# Log subscriber for soft validation errors.
class SoftValidator::LogSubscriber < ActiveSupport::LogSubscriber
  class << self
    # Helper method to attach the log subscriber.
    def attach
      attach_to :soft_validator
    end

    # Helper method to detach the log subscriber.
    def detach
      detach_from :soft_validator
    end
  end

  def validation_error(event)
    return unless logger&.warn?

    error = event.payload[:error]
    record = error.base
    ref = record.class.name
    ref = "#{ref}(#{record.id})" if record.respond_to?(:id)
    message = "Soft validation error on #{ref}: #{error.full_message}"

    logger.warn(message)
  end

  def logger
    self.class.logger
  end
end
