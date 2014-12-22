class DocumentVersion < ActiveRecord::Base
  attr_accessible :editorial, :major, :technical

  belongs_to :release
  belongs_to :document

  has_many :document_files

  def self.chars_version
    [0,1,2,3,4,5,6,7,8,9,
      'a','b','c','d','e','f','g','h','i',
      'jh','k','l','m','n','o','p','q','r',
      's','t','u','v','w','x','y','z'
    ]
  end

  def self.parse_version(version)
    m = version.match(/(\d+)[\._](\d+)[\._](\d+)/)

    res = {
        :editorial => m[1].to_i,
        :major => m[2].to_i,
        :technical => m[3].to_i
    }
  end

  def version(format = nil)
    case format
      when :letters then
        "%s%s%s" % [
          DocumentVersion.chars_version[editorial],
          DocumentVersion.chars_version[major],
          DocumentVersion.chars_version[technical]
        ]
      else "v#{editorial}.#{major}.#{technical}"
    end
  end

  def has_format?(format)
    # puts "Has format ? #{(document_files.where(:format => format).count != 0)}"
    (document_files.where(:format => format).count != 0)
  end

  def get_file(format)
    document_files.where(:format => format).first
  end

  def retrieve_format(format)

    case format
      when :pdf   then return retrieve_pdf
      when :html  then return retrieve_html
      when :doc   then return retrieve_doc
      else raise "Unknown format #{format}"
    end

    false
  end

  def analyze_pdf
    pdf_file = get_file(:pdf)

    if !pdf_file.nil?
      pdf_file.analyze_pdf
    end
  end

private

  # Get PDF from ETSI servers
  def retrieve_pdf
    puts "Getting PDF".green

    spec_serie = document.spec_serie.index

    lower_bound = ((document.spec_number)/100).to_i * 100
    higher_bound = lower_bound + 99

    url_path  = "http://www.etsi.org/deliver/etsi_ts/"
    url_path += "1%02d%03d_1%02d%03d/" % [spec_serie,lower_bound,spec_serie,higher_bound]

    if document.spec_part.nil?
        doc_nb = "%02d%03d" % [spec_serie,document.spec_number]
      else
        doc_nb = "%02d%03d%02d" % [spec_serie,document.spec_number,document.spec_part]
    end

    url_path += "1#{doc_nb}/"
    url_path += "%02d.%02d.%02d_60/" % [editorial,major,technical]
    url_path += "ts_1#{doc_nb}v%02d%02d%02dp.pdf" % [editorial,major,technical]

    begin
      puts "... from #{url_path}".yellow

      Net::HTTP.get_response( URI(url_path) ) { |res|
        if res.is_a?(Net::HTTPSuccess)
          local_path = DocumentFile.get_local_path(self, :pdf)
          puts "Storing to #{local_path}"

          FileUtils.mkdir_p(local_path.dirname) unless File.exists?(local_path.dirname)
 
          File.open(local_path, "wb") { |io|
              res.read_body do |segment|
                  io.write(segment)
              end
          }

          doc_file = document_files.new
          doc_file.format = :pdf
          doc_file.analyze
          doc_file.save

          return true
        end
      }
        
    rescue
      puts "Error getting PDF @ #{url_path}".red
    end

    false
  end

  def retrieve_html
    puts "Getting HTML".green

    if !has_format? :pdf and !retrieve_pdf
      return false
    end

    path_pdf = DocumentFile.get_local_path(self, :pdf)
    path_html = DocumentFile.get_local_path(self, :html)

    begin
      if `pdf2htmlEX #{path_pdf} --dest-dir #{Pathname(path_html).dirname}`
        doc_file = document_files.new
        doc_file.format = :html
        doc_file.analyze
        doc_file.save
      end
    end
  end

  def retrieve_doc
    puts "Getting DOC".green

    spec_serie = document.spec_serie.index

    url_path  = "http://www.3gpp.org/ftp/Specs/archive/"
    url_path += "%02d_series/" % spec_serie

    if document.spec_part.nil?
        suffix = document.name.end_with?("U") ? "U" : ""
        url_path += "%02d.%02d%s/" % [spec_serie,document.spec_number,suffix]
        url_path += "%02d%02d%s-%s.zip" % [spec_serie,document.spec_number,suffix,version(:letters)]
      else
        url_path += "%02d.%02d-%d/" % [spec_serie,document.spec_number,document.spec_part]
        url_path += "%02d%02d-%d-%s.zip" % [spec_serie,document.spec_number,document.spec_part,version(:letters)]
    end

    begin
      puts "... from #{url_path}".yellow
      
      # Getting zip
      Net::HTTP.get_response( URI(url_path) ) { |res|
        if res.is_a?(Net::HTTPSuccess)
          local_path_zip = DocumentFile.get_local_path(self, :zip)
          local_path = DocumentFile.get_local_path(self, :doc)

          puts "Storing to #{local_path}"

          FileUtils.mkdir_p(local_path.dirname) unless File.exists?(local_path.dirname)
 
          File.open(local_path_zip, "wb") { |io|
              res.read_body do |segment|
                  io.write(segment)
              end
          }

          # Extracting zip
          Zip::ZipFile.open(local_path_zip) do |zf|
            zf.each do |e|
              puts "Extracting ... #{e.name}"
              zf.extract(e.name, local_path)
              break
            end
          end

          # Removing zip
          File.delete(local_path_zip)

          doc_file = document_files.new
          doc_file.format = :doc
          doc_file.analyze
          doc_file.save

          return true
        end
      }
        
    # rescue
    #   puts "Error getting DOC @ #{url_path}".red
    end

    false
  end

end
