require 'spec_helper'
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
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/hostname_facts')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.number_of_hostnames).to eql(2)
  end

  it 'can return the number of nodes with a technical_team' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/technical_team_facts')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.technical_team_count).to eql(2)
  end

  it 'returns a list of hostnames' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/hostname_facts')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.hostnames).to be_kind_of(Array)
  end

  it 'can return a department for a given hostname' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/department_facts')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.get_department('sul-frda-prod.stanford.edu')).to eql('dlss')
  end

  it 'can return a technical_team for a given hostname' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/technical_team_for_hostname')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.get_technical_team('some-server-prod.stanford.edu')).to eql('bar')
  end

  it 'can return a user_advocate for a given hostname' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/user_advocate_for_hostname')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.get_user_advocate('some-server-prod.stanford.edu')).to eql('foo')
  end

  it 'can return a project for a given hostname' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/project_for_hostname')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.get_project('some-server-prod.stanford.edu')).to eql('baz')
  end

  it 'can return an sla_level for a given hostname' do
    response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/sla_for_hostname')).read
    stub_request(:any, /sulpuppet-db/).to_return(status: 200,
                                                 body: response,
                                                 headers: { 'Content-Type' => 'application/json' })
    expect(@puppetdb_reporter.get_sla_level('some-server-prod.stanford.edu')).to eql('low')
  end

  it 'returns an array of facts for a hostname' do
    departments_response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/department_facts')).read
    technical_teams_response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/technical_team_facts')).read
    user_advocates_response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/user_advocate_for_hostname')).read
    projects_response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/project_for_hostname')).read
    sla_levels_response = File.open(File.join(File.dirname(__FILE__), '../fixtures/files/sla_for_hostname')).read
    stub_request(:any, /sulpuppet-db/).to_return({ status: 200,
                                                   body: departments_response,
                                                   headers: { 'Content-Type' => 'application/json' } },
                                                 { status: 200,
                                                   body: technical_teams_response,
                                                   headers: { 'Content-Type' => 'application/json' } },
                                                 { status: 200,
                                                   body: user_advocates_response,
                                                   headers: { 'Content-Type' => 'application/json' } },
                                                 { status: 200,
                                                   body: projects_response,
                                                   headers: { 'Content-Type' => 'application/json' } },
                                                 { status: 200,
                                                   body: sla_levels_response,
                                                   headers: { 'Content-Type' => 'application/json' } })
    expect(@puppetdb_reporter.generate_line_of_content('sul-frda-prod.stanford.edu')).to eql(['sul-frda-prod.stanford.edu',
                                                                                                'dlss','foo','foo',
                                                                                                'baz','low'])
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

  it 'reads in a csv report' do
    expect(@puppetdb_reporter.read_csv('spec/fixtures/files/puppetdb.csv')).to be_kind_of CSV::Table
  end

  it 'returns a CSV::Row based on hostname' do
    expect(@puppetdb_reporter.get_single_record_from_csv('spec/fixtures/files/puppetdb.csv', 'libdbdev2.stanford.edu')).to be_kind_of CSV::Row
  end
end
