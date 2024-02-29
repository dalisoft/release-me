require 'simplecov'

SimpleCov.start do
  command_name 'Unit Tests'

  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  else
    require 'coveralls'

    formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
    ]
  end

  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  coverage_dir 'coverage'
end
