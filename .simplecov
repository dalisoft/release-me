SimpleCov.start do
  command_name 'Unit Tests'

  if ENV['CI']
    require 'coveralls'

    formatter = Coveralls::SimpleCov::Formatter
  else
    formatter = SimpleCov::Formatter::HTMLFormatter
  end

  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  coverage_dir 'coverage'
end
