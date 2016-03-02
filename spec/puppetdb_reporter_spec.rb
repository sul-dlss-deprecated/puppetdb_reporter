$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'puppetdb_reporter.rb'

describe 'PuppetdbReporter' do
  it 'can instantiate' do
    expect(PuppetdbReporter.new).to be_kind_of(PuppetdbReporter)
  end
end
