require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    require 'coveralls'

    formatter Coveralls::SimpleCov::Formatter
  else
    SimpleCov::Formatter::HTMLFormatter
  end

  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  command_name 'Unit Tests'
  coverage_dir 'coverage'
end
