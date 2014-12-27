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

def init_spec_numbering
    puts "Init ... spec numbering".cyan

    source_page = "http://www.3gpp.org/specification-numbering"
    source_path = '/html/body/div/div[2]/div[5]/div/table/tbody/tr'

    source_html = Nokogiri::HTML(open(source_page))

    # scopes = SpecScope.scope_gsm_1
    # all = scopes[0]
    # scope_gsm_2 = scopes[1]
    # scope_3g = scopes[2]

    source_html.xpath(source_path).each do |elmt|

        title = elmt.elements[0].text
        puts title.cyan

        i = 0
        scopes = [3,2,1]

        elmt.elements[1..3].each do |serie|
            if not serie.text[/(\d+) series/].nil?
                num = serie.text[/(\d+) series/].to_i

                puts num.to_s.green

                SpecSerie.create( {
                    :index => num,
                    :spec_scope_id => scopes[i],
                    :subject => title })
            end

            i += 1
        end
    end

end

def process_spec(spec)

    # For each Document
    doc = Document.find_or_initialize_by_name(spec[:no])
    if doc.new_record?
        puts "\tCreating document #{spec[:no]}".yellow
        # If we need to make this
        doc.title = spec[:title]
        doc.parse_no

        doc.save!
    else
        puts "\tFound document #{spec[:no]} => #{doc.id}".cyan

        if doc.spec_serie_id.nil?
            doc.parse_no
            doc.save!
        end
    end

    spec[:versions].each do |version|
        if doc.document_versions.where(version[:hash]).count == 0
            puts "\t\tCreating version #{version[:hash]}".yellow
            doc_version = doc.document_versions.create(version[:hash])
            doc_version.release = version[:release]
            doc_version.save!
        else
            puts "\t\tFound version #{version[:hash]}".cyan
        end

        # Auto cache PDF
        #puts doc.document_versions.where(version_hash).first.retrieve_format :pdf
    end
end

def init_spec_matrix
    puts "Init ... spec matrix".cyan

    source_page = "http://www.3gpp.org/ftp/Specs/html-info/SpecReleaseMatrix.htm"
    # source_page = "SpecReleaseMatrix.htm"

    source_html = Nokogiri::HTML(open(source_page))

    releases = []

    # Header
    puts "Releases".cyan

    source_path = '//*[@id="a3dyntab"]/thead/tr'
    source_html.xpath(source_path).first.elements[3..-1].each do |elmt|
        puts elmt.text.red
        release = Release.find_or_create_by_name(elmt.text)
        releases.push(release)
    end

    specs = []

    # Content
    source_path = '//*[@id="a3dyntab"]/tbody/tr'
    source_html.xpath(source_path).each do |elmt|
        if not elmt.xpath("td[2]").text[/withdrawn/]

            # Spec is not withdraw, inserting in db
            spec_no = elmt.elements[0].text.strip
            spec_title = elmt.elements[1].text.strip
            spec_wg = elmt.elements[2].text.strip

            if ARGV.length == 0 or spec_no.starts_with? ARGV[0]
                spec = {
                    :no => spec_no,
                    :title => spec_title,
                    :wg => spec_wg,
                    :versions => []
                }

                # For each Version
                idx = 0
                elmt.elements[3..-1].each do |elmt|
                    if (not elmt.text.empty?) and (elmt.text != "none")
                        version_hash = DocumentVersion.parse_version(elmt.text)
                        version_info = {
                            :hash => version_hash,
                            :release => releases[idx] 
                        } 
                        raise "Unknown rel #{idx}" if version_info[:release].nil?
                        spec[:versions].push version_info
                    end

                    idx += 1
                end

                specs.push spec
            end

        else
            #puts elmt.xpath("td[1]").text.red
        end
    end

    # Analyze
    nb_threads = 2
    threads = (1..nb_threads).map do |i|
        Thread.new(i) do |i|
            idx = 0
            loop do
                spec_idx = (idx * nb_threads) + i
                break if spec_idx >= specs.length 

                begin
                    process_spec specs[spec_idx]
                rescue Exception => e
                    puts "Error while parsing #{spec_idx}: #{e}"
                end

                idx += 1
            end
        end
    end

    threads.each {|t| t.join}
end

# Script
if __FILE__ == $0

    puts 'Init 3GPP'.green

    load_rails()

    a = Time.now

    init_spec_numbering() if ARGV.length == 0

    init_spec_matrix()

    b = Time.now

    print_chrono a, b

    puts
end
