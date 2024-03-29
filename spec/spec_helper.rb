# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

begin
  require "simplecov"
  SimpleCov.start do
    add_filter ["/spec/", "/app/", "/config/", "/db/"]
  end
rescue LoadError
end

Bundler.require(:default, :test)

class TestModel
  include ActiveModel::Validations

  attr_accessor :id, :name, :value, :units

  validates :name,
    presence: true,
    soft: {length: {maximum: 10}, format: {with: /\A[a-z]/i}}
  validates :value,
    soft: {numericality: {greater_than: 0, allow_nil: true}, enforced: true}
  validates :units,
    soft: {inclusion: {in: ["meters", "feet"]}, if: -> { value.present? }}

  def initialize(attributes = {})
    attributes.each do |name, value|
      send(:"#{name}=", value)
    end
  end
end

RSpec.configure do |config|
  config.order = :random
end

SoftValidator::LogSubscriber.detach

def capture_notifications
  errors = []

  subscription = SoftValidator.subscribe do |error|
    errors << error
  end

  yield

  ActiveSupport::Notifications.unsubscribe(subscription)

  errors
end
