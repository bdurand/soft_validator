# frozen_string_literal: true

require "active_model"

class SoftValidator < ActiveModel::EachValidator
  VERSION = File.read(File.join(__dir__, "..", "VERSION")).strip.freeze

  ERROR_EVENT = "validation_error.soft_validator"

  class << self
    def enforced?
      @enforced ||= false
    end

    attr_writer :enforced

    def subscribe(&block)
      ActiveSupport::Notifications.subscribe(ERROR_EVENT) do |event|
        yield(event.payload[:error])
      end
    end
  end

  def initialize(options)
    super
    @validators = wrapped_validators(options[:class])
  end

  def validate_each(record, attribute, value)
    existing_errors = record.errors.errors.dup
    @validators.each do |validator|
      validator.validate_each(record, attribute, value)
      next if enforced?

      (record.errors.errors - existing_errors).each do |error|
        record.errors.delete(error.attribute, error.type, **error.options)
        ActiveSupport::Notifications.instrument(ERROR_EVENT, error: error)
      end
    end
  end

  def enforced?
    enforced = options[:enforced]
    enforced = enforced.call if enforced.is_a?(Proc)
    enforced || self.class.enforced?
  end

  private

  def wrapped_validators(klass)
    options.except(:enforced, :if, :unless, :on).map do |validator_name, validator_options|
      class_name = "#{validator_name.to_s.camelize}Validator"

      begin
        validator = klass.const_get(class_name)
      rescue NameError
        raise ArgumentError, "Unknown validator: '#{class_name}'"
      end

      validator_options = {} unless validator_options.is_a?(Hash)
      validator.new(validator_options.merge(class: klass, attributes: attributes))
    end
  end
end

require_relative "soft_validator/log_subscriber"

if defined?(Rails::Railtie)
  require_relative "soft_validator/railtie"
end
