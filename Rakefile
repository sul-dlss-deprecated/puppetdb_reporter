begin
  require 'rspec/core/rake_task'
  import 'lib/puppetdb_reporter.rb'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec

  task :generate_report do
    puppetdb_reporter = PuppetdbReporter.new('http://sulpuppet-db.stanford.edu:8080')
    puppetdb_reporter.write_csv_report
  end
rescue LoadError
  # no rspec available
end
