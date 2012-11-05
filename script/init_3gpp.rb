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
    source_path = '//*[@id="main"]/div[2]/table/tbody/tr'

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

def init_spec_matrix
    puts "Init ... spec matrix".cyan

    # source_page = "http://www.3gpp.org/ftp/Specs/html-info/SpecReleaseMatrix.htm"
    source_page = "SpecReleaseMatrix.htm"

    source_html = Nokogiri::HTML(open(source_page))

    releases = []

    # Header
    puts "Releases".cyan

    source_path = "/html/body/table/tr[@bgcolor = \"#BEF781\"]"
    source_html.xpath(source_path).first.elements[3..-1].each do |elmt|
        puts elmt.text.red
        release = Release.find_or_create_by_name(elmt.text)
        releases.push(release)
    end

    # Content
    source_path = "/html/body/table/tr[@bgcolor != \"#BEF781\"]"
    source_html.xpath(source_path).each do |elmt|
        if not elmt.xpath("td[2]").text[/withdrawn/]

            # Spec is not withdraw, inserting in db
            spec_no = elmt.elements[0].text.strip
            spec_title = elmt.elements[1].text.strip
            spec_wg = elmt.elements[2].text.strip

            if ARGV.length == 0 or spec_no.starts_with? ARGV[0]

                # For each Document
                doc = Document.find_or_initialize_by_name(spec_no)
                if doc.new_record?
                    puts "\tCreating document #{spec_no}".yellow
                    # If we need to make this
                    doc.title = spec_title
                    doc.parse_no(spec_no)

                    doc.save!
                else
                    puts "\tFound document #{spec_no} => #{doc.id}".cyan

                    if doc.spec_serie_id.nil?
                        doc.parse_no(spec_no)
                        doc.save!
                    end
                end

                # For each Version
                idx = 0
                elmt.elements[3..-1].each do |elmt|
                    if (not elmt.text.empty?) and (elmt.text != "none")
                        version_hash = DocumentVersion.parse_version(elmt.text)

                        if doc.document_versions.where(version_hash).count == 0
                            puts "\t\tCreating version #{version_hash}".yellow
                            version = doc.document_versions.create(version_hash)
                            version.release = releases[idx]
                            version.save!
                        else
                            puts "\t\tFound version #{version_hash}".cyan
                        end

                        puts doc.document_versions.where(version_hash).first.retreive_pdf
                    end

                    idx += 1
                end
            end

        else
            #puts elmt.xpath("td[1]").text.red
        end
    end
end

# Script
if __FILE__ == $0

    puts 'Init 3GPP'.green
  
    load_rails()

    a = Time.now
    
    #init_spec_numbering()
    init_spec_matrix()

    b = Time.now

    print_chrono a, b

    puts
end
