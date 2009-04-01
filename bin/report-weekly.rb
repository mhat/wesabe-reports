#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__) + "/../lib"
require 'rubygems' 
require 'erb'
require 'chronic'
require 'wesabe'
require 'wesabe/stats/util'
require 'wesabe/stats/weekly'


class WeeklyController
  def initialize (config)
    
    username = config['username']
    password = config['password']
    sdate    = config['sdate']
    edate    = config['edate']
    
    wesabe   = Wesabe.new(username, password)
    
    ## setup the tags stats container 
    @tstats   = Wesabe::Stats::Tags::InMonthGroupByWeek.new(Time.parse(sdate))
    @tstats.filter('transfer')
    
    ## collect txactions and store thos in the stats container
    wesabe.txactions_for(sdate, edate).each { |txn| @tstats.add(txn) }
    
    @today   = Time.now
    @week    = @tstats.weeks.select{|week| week[0] <= @today && week[1] > @today}
    @week    = @week.shift if @week.size > 0
    @weeks   = @tstats.weeks
    
    @tags    = @tstats.sort{ |a,b| b.total.abs <=> a.total.abs }
    @targets = wesabe.targets
    
    
  end
    
  def get_binding 
    return binding
  end
end

config = YAML.load(File.read(ENV['HOME'] + "/.wesabe.console")) rescue {}

if (config.class.is_a?(Hash))
  if (!config.has_key?('username') || !config.has_key?('password'))
    puts "Put your credentials in HOME/.wesabe.console"
    exit
  end
end

if (ARGV.length != 2)
  puts "report-weekly.rb start-date end-date"
  exit
else
  config['sdate'] = ARGV[0]
  config['edate'] = ARGV[1]
end


template = File.open((File.dirname(__FILE__) + '/../app/views/weekly.html.erb'), "r").read
binding  = WeeklyController.new(config).get_binding

puts ERB.new(template).result(binding)
