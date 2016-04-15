require 'spec_helper'
require 'puppetdb_reporter.rb'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

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

  it 'can return the number of hostnames', :vcr do
    expect(@puppetdb_reporter.number_of_hostnames).to eql(466)
  end

  it 'can return the number of nodes with a technical_team', :vcr do
    expect(@puppetdb_reporter.technical_team_count).to eql(116)
  end

  it 'returns a list of hostnames', :vcr do
    expect(@puppetdb_reporter.hostnames).to be_kind_of(Array)
  end

  it 'can return a department for a given hostname', :vcr do
    expect(@puppetdb_reporter.get_department('sul-frda-prod.stanford.edu')).to eql('dlss')
  end

  it 'can return a technical_team for a given hostname', :vcr do
    expect(@puppetdb_reporter.get_technical_team('sul-frda-prod.stanford.edu')).to eql('webteam')
  end

  it 'can return a user_advocate for a given hostname', :vcr do
    expect(@puppetdb_reporter.get_user_advocate('sul-frda-prod.stanford.edu')).to eql('caster')
  end

  it 'can return a project for a given hostname', :vcr do
    expect(@puppetdb_reporter.get_project('sul-frda-prod.stanford.edu')).to eql('frda')
  end

  it 'can return an sla_level for a given hostname', :vcr do
    expect(@puppetdb_reporter.get_sla_level('sul-frda-prod.stanford.edu')).to eql('low')
  end

  it 'returns an array of facts for a hostname', :vcr do
    expect(@puppetdb_reporter.generate_line_of_content('sul-frda-prod.stanford.edu')).to eql(['sul-frda-prod.stanford.edu',
                                                                                                'dlss','webteam','caster',
                                                                                                'frda','low'])
  end

  it 'generates an array of facts for each hostname' do
    puppetdb_reporter = double('puppetdb_reporter')
    allow(puppetdb_reporter).to receive_messages(:generate_all_content => [["sulreports-db-dev.stanford.edu", "systeam", nil, nil, "reports", "low"],
                                                                           ["coursework-dev5.stanford.edu", nil, nil, nil, nil, nil]])
    expect(puppetdb_reporter.generate_all_content).to be_kind_of(Array)
  end

  it 'writes a csv report from generated content' do
    puppetdb_reporter = double('puppetdb_reporter')
    allow(puppetdb_reporter).to receive_messages(:write_csv_report => [["hostname", "department", "technical_team", "user_advocate", "project", "sla_level"],
                                                                       ["argo-prod-a.stanford.edu", "dlss", "infrastructure", nil, "argo", "low"]])
    expect(puppetdb_reporter.write_csv_report).to be_kind_of(Array)
  end

end
