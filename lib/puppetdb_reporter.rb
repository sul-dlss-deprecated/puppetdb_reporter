require 'puppetdb'
require 'json'

class PuppetdbReporter

  attr_reader :endpoint
  attr_reader :client

  def initialize(endpoint)
    @endpoint = endpoint
    @client = PuppetDB::Client.new(server: @endpoint)
  end

  def fact_query(hostname)
    response = @client.request('facts', ['=', 'name', 'hostname'])
    #  my_hash = JSON.parse(response.data)
    #  puts my_hash.class
    puts response.data.class
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

end
