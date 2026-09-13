if ENV['CI']
  require 'coveralls'

  SimpleCov.formatter Coveralls::SimpleCov::Formatter
else
  SimpleCov.formatter SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.minimum_coverage 15
SimpleCov.skip 'tests/'
SimpleCov.skip 'spec/'
SimpleCov.skip '/.git/'
SimpleCov.skip '/node_modules/'
SimpleCov.skip 'bash_unit'

SimpleCov.coverage_dir 'coverage'
