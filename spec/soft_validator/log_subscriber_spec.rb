# frozen_string_literal: true

require_relative "../spec_helper"

describe SoftValidator::LogSubscriber do
  def capture_logger
    out = StringIO.new
    saved_logger = SoftValidator::LogSubscriber.logger
    SoftValidator::LogSubscriber.logger = Logger.new(out)
    begin
      yield
    ensure
      SoftValidator::LogSubscriber.logger = saved_logger
    end
    out.string
  end

  it "logs validation errors" do
    record = TestModel.new(id: 1)
    error = ActiveModel::Error.new(record, :name, :invalid)
    event = ActiveSupport::Notifications::Event.new(
      "validation_error.soft_validator", nil, nil, "123", {error: error}
    )

    log_subscriber = SoftValidator::LogSubscriber.new
    logs = capture_logger { log_subscriber.validation_error(event) }
    expect(logs).to include("Soft validation error on TestModel(1): Name is invalid")
  end
end
