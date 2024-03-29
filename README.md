# SoftValidator

[![Continuous Integration](https://github.com/bdurand/soft_validator/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/soft_validator/actions/workflows/continuous_integration.yml)
[![Regression Test](https://github.com/bdurand/soft_validator/actions/workflows/regression_test.yml/badge.svg)](https://github.com/bdurand/soft_validator/actions/workflows/regression_test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/soft_validator.svg)](https://badge.fury.io/rb/soft_validator)

This gem adds a soft validator for use with ActiveModel/ActiveRecord. It is intended to solve issues that can arise when adding new validations to an existing model. Once your model is running in production and taking real world inputs, it can be risky to add a new validation since it might break some of those inputs. This gem allows you to soft launch a new validation by running it in a non-enforcing mode. This will allow you to see what would have failed without actually failing the validation. You can then fix the issues and turn on the validation.

## Usage

The easiest way to use the gem is simply to wrap your existing validations with a `:soft` validation.

```ruby
class Thing < ApplicationRecord
  validates :units, presence: true, soft: {inclusion: {in: ["feet", "meters"]}}
end
```

Each of the validations in the `:soft` validation will still be run when the record is validated. However, if there are any errors, they will not be added to the record `errors` object and the record will still be considered valid.

### Notifications

Soft validation errors are published via ActiveSupport notifications. You can handle errors generted from soft validations by subscribing to the `validation_error.soft_validator` event. For instance, you could log the errors to the Rails logger by adding this code to an initializer:

```ruby
ActiveSupport::Notifications.subscribe("validation_error.soft_validator") do |event|
  error = event.payload[:error]
  message = "Soft validation error on {error.base.class.name}(#{error.base.id}): #{error.full_message}"
  Rails.logger.warn(message)
end
```

You can also the `SoftValidator.subscribe` helper method to set up subscriptions. This code will do the same thing as the code above:

```ruby
SoftValidator.subscribe do |error|
  message = "Soft validation error on {error.base.class.name}(#{error.base.id}): #{error.full_message}"
  Rails.logger.warn(message)
end
```

If you just want to log the errors, you can use the built in log subscriber instead (it does the same thing as the above subscription). You **do not** need to do this in a Rails application; it will be done for you automatically.

```ruby
SoftValidator::LogSubscriber.attach
```

You can disable the log subscriber by calling `SoftValidator::LogSubscriber.detach`.

### Enforcing with feature flags

You can turn a soft validation into a hard validation by setting the `:enforce` option to `true`. This will cause the validation to generate errors as normal. You can use this option to enable validation with a feature flag.

```ruby
class Thing < ApplicationRecord
  validates :units,
            presence: true,
            soft: {
              inclusion: {in: ["feet", "meters"]},
              enforce: ENV.fetch("ENFORCE_UNITS", !Rails.env.production?.to_s) == "true"
            }
end
```

The global default for enforcing soft validations can be changed by setting `SoftValidator.enforce`. If it is set to `true`, soft validations will be enforced by default. In Rails applications this is set automatically in the development and test environments since you would typically want to see the errors in those environments so that you can fix them.

### Conditional options

If you want to add any of the standard conditional options for the validator (i.e. `:if`, `:unless`, `:on`, `:prepend`), you need to add it to the soft validator and not the wrapped validator.

```ruby
class Thing < ApplicationRecord
  validates :units,
            soft: {inclusion: {in: ["feet", "meters"]}, if: :units_changed?}

  # This won't work; the `if` option cannot be on the wrapped validator:
  # validates :units,
  #           soft: {inclusion: {in: ["feet", "meters"], if: :units_changed?}}
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "soft_validator"
```

Then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install gem "soft_validator"
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
