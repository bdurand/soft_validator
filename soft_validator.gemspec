Gem::Specification.new do |spec|
  spec.name = "soft_validator"
  spec.version = File.read(File.join(__dir__, "VERSION")).strip
  spec.authors = ["Brian Durand"]
  spec.email = ["bbdurand@gmail.com"]

  spec.summary = "ActiveModel/ActiveRecord validator that can wrap other validators to notify of errors so that new validations can be safely added to an existing model."
  spec.homepage = "https://github.com/bdurand/soft_validator"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_files = %w[
    .
    Appraisals
    Gemfile
    Gemfile.lock
    Rakefile
    config.ru
    assets/
    bin/
    gemfiles/
    spec/
  ]
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| ignore_files.any? { |path| f.start_with?(path) } }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 5.2"

  spec.add_development_dependency "bundler"

  spec.required_ruby_version = ">= 2.5"
end
