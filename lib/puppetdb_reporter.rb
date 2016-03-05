require 'puppetdb'
require 'json'
require 'csv'
require 'benchmark'

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
    get_fact_value(hostname, 'department')
  end

  def get_technical_team(hostname)
    get_fact_value(hostname, 'technical_team')
  end

  def get_user_advocate(hostname)
    get_fact_value(hostname, 'user_advocate')
  end

  def get_project(hostname)
    get_fact_value(hostname, 'project')
  end

  def get_sla_level(hostname)
    get_fact_value(hostname, 'sla_level')
  end

  def get_fact_value(hostname, fact_name)
    response = client.request('facts', ['and',
                                         ['=', 'certname', hostname],
                                         ['=', 'name', fact_name]])
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
    Benchmark.bm do |b|
            b.report {
      hostnames.collect { |x| all_content << generate_line_of_content(x) }
      }
    end
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
