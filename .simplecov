require 'coveralls'

SimpleCov.start do
  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"
end

SimpleCov.formatters = [Coveralls::SimpleCov::Formatter]
SimpleCov::ResultMerger.merged_result.format!
