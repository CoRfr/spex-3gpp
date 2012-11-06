#!/usr/bin/env ruby

require 'open-uri'
require 'colored'
require 'ap'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'poppler'

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

def walk_index(indexer, depth = 0)
    indexer.each do |i|

        ap i.action.dest.page_num
        ap i.action.dest.top
        child = i.child

        walk_index(child, depth + 1) if child.nil? == false and depth < 1
    end
end

def analyze_pdf(path)
    doc = Poppler::Document.new(path)
    indexer = Poppler::IndexIter.new(doc)

    pages = doc.n_pages
    puts "This is the number of pages #{pages}".cyan

    walk_index(indexer)
end

# Script
if __FILE__ == $0

    puts 'PDF Analyzer'.green
  
    if ARGV.length == 0
        puts "Path required".red
        exit -1
    end

    load_rails()

    a = Time.now
    
    analyze_pdf(ARGV[0])

    b = Time.now

    print_chrono a, b

    puts
end
