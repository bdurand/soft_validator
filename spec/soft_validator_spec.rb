# frozen_string_literal: true

require_relative "spec_helper"

describe SoftValidator do
  let(:valid_attributes) do
    {
      name: "Test",
      value: 1,
      units: "meters"
    }
  end

  let(:model) { TestModel.new(valid_attributes) }

  it "does not add errors when a soft validation fails" do
    model.name = "12345678901"
    model.valid?
    expect(model.errors[:name]).to be_empty
  end

  it "adds errors when a soft validation is enforced" do
    model.value = -1
    model.valid?
    expect(model.errors[:value].size).to eq 1
    expect(model.errors[:value].first).to eq "must be greater than 0"
  end

  it "publishes errors when a soft validation fails" do
    model.name = "12345678901"
    errors = capture_notifications do
      model.valid?
    end

    expect(errors.size).to eq(2)
    expect(errors.map(&:base).uniq).to eq [model]
    expect(errors.map(&:attribute).uniq).to eq [:name]
    expect(errors.map(&:type)).to match_array [:invalid, :too_long]
  end

  it "honors standard validation options in the soft validator" do
    model.units = nil
    errors = capture_notifications do
      model.valid?
    end
    expect(errors.map(&:message)).to eq ["is not included in the list"]

    model.value = nil
    errors = capture_notifications do
      model.valid?
    end
    expect(errors).to be_empty
  end
end
