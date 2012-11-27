#!/usr/bin/env ruby

require 'open-uri'
require 'colored'
require 'ap'
require 'net/http'
require 'uri'
require 'nokogiri'

def print_chrono(t_a, t_b)
    puts "... took %0.2f sec".yellow % (t_b - t_a)
end

def load_rails
    puts "Loading Rails".cyan

    a = Time.now
    ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
    require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
    b = Time.now

    print_chrono a, b
end

# Script
if __FILE__ == $0

    puts 'Fix PDFs'.green
  
    load_rails()

    a = Time.now
    
    DocumentFile.includes({:document_version => :document }).where( { :format => :pdf, :nb_pages => nil } ).each do |df|
        print "#{df.local_path} => "
        res = df.analyze_pdf
        puts (res) ? res.to_s.green : res.to_s.red
    end

    b = Time.now

    print_chrono a, b

    puts
end
