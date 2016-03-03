$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'puppetdb_reporter.rb'

describe 'PuppetdbReporter' do

  before(:all) do
    @puppetdb_reporter = PuppetdbReporter.new('http://sulpuppet-db.stanford.edu:8080')
  end

  it 'can instantiate with an endpoint url' do
    expect(@puppetdb_reporter).to be_kind_of(PuppetdbReporter)
  end

  it 'can return its endpoint url' do
    expect(@puppetdb_reporter.endpoint).to eql('http://sulpuppet-db.stanford.edu:8080')
  end

  it 'has a PuppetDB::Client' do
    expect(@puppetdb_reporter.client).to be_kind_of(PuppetDB::Client)
  end

  it 'can return the number of hostnames' do
    expect(@puppetdb_reporter.number_of_hostnames).to eql(464)
  end

  #how many things have a technical_team
  it 'can return the number of nodes with a technical_team' do
    expect(@puppetdb_reporter.technical_team_count).to eql(114)
  end

  it 'return a list of hostnames' do
    expect(@puppetdb_reporter.hostnames).to be_kind_of(Array)
  end

  #foreach hostname what is it's technical_team

end
