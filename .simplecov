
SimpleCov.start do
  minimum_coverage 15
  add_filter "tests/"
  add_filter "/.git/"
  add_filter "bash_unit"

  require 'coveralls'
  SimpleCov.profiles.define 'coveralls' do
    SimpleCov.formatters = [Coveralls::SimpleCov::Formatter]
  end
end
