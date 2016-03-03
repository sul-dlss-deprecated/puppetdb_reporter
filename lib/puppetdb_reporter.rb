require 'puppetdb'
require 'json'
require 'csv'

class PuppetdbReporter

  attr_reader :endpoint
  attr_reader :client

  def initialize(endpoint)
    @endpoint = endpoint
    @client = PuppetDB::Client.new(server: @endpoint)
  end

  def number_of_hostnames
    response = @client.request('facts', ['=', 'name', 'hostname'])
    response.data.count
  end

  def technical_team_count
    response = @client.request('facts', ['=', 'name', 'technical_team'])
    response.data.count
  end

  def hostnames
    response = @client.request('facts', ['=', 'name', 'hostname'])
    response.data.collect { |x| x['certname'] }
  end

  # the facts we want are:
  # department: 'dlss'
  # technical_team: 'webteam'
  # user_advocate: 'caster'
  # project: 'frda'
  # sla_level: 'low'
  #
  # and a fact looks like:
  # {"value" : "webteam", "name" : "technical_team", "certname" : "sul-frda-prod.stanford.edu"}

  def get_department(hostname)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', 'department']])
    response.data.collect { |x| x['value'] }.first
  end

  def get_technical_team(hostname)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', 'technical_team']])
    response.data.collect { |x| x['value'] }.first
  end

  def get_user_advocate(hostname)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', 'user_advocate']])
    response.data.collect { |x| x['value'] }.first
  end

  def get_project(hostname)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', 'project']])
    response.data.collect { |x| x['value'] }.first
  end

  def get_sla_level(hostname)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', 'sla_level']])
    response.data.collect { |x| x['value'] }.first
  end

  def generate_line_of_content(hostname)
    line = []
    line << hostname
    line << get_department(hostname)
    line << get_technical_team(hostname)
    line << get_user_advocate(hostname)
    line << get_project(hostname)
    line << get_sla_level(hostname)
    line
  end

  def generate_all_content
    all_content = []
    hostnames.collect { |x| all_content << generate_line_of_content(x) }
    all_content
  end

  def write_csv_report
    content = generate_all_content
    headers = ['hostname', 'department', 'technical_team', 'user_advocate', 'project', 'sla_level']
    content.unshift(headers)
    CSV.open("puppetdb.csv", "wb") do |csv|
      content.collect { |x| csv << x }
    end
  end

end
