require 'simplecov_small_badge'

SimpleCov.start do
  command_name 'Unit Tests'

  if ENV['CI']
    require 'coveralls'

    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCovSmallBadge::Formatter,
      Coveralls::SimpleCov::Formatter
    ])
  else
    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCovSmallBadge::Formatter,
    ])
  end

  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  coverage_dir 'coverage'
end

# configure any options you want for SimpleCov::Formatter::BadgeFormatter
SimpleCovSmallBadge.configure do |config|
  # does not created rounded borders
  config.rounded_border = true
end
