require 'simplecov'

SimpleCov.start do
  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  command_name 'Unit Tests'
  coverage_dir 'coverage'

  formatter SimpleCov::Formatter::SimpleFormatter
end unless SimpleCov.running
