class Document < ActiveRecord::Base
  attr_accessible :name, :title, :description, :spec_serie_id, :spec_number, :spec_part

  belongs_to :spec_serie

  has_many :document_versions

  def self.parse_no(spec_no)

    m = spec_no.match(/(\d+)[\._](\d+)(?:-(\d))?/)

    res = {
        :serie => m[1].to_i,
        :number => m[2].to_i
    }

    res[:part] = m[3].to_i if not m[3].nil?

    res
  end

  def self.desc_to_name(desc)
    name = "%02d.%d" % [desc[:serie],desc[:number]]
    name += "-#{desc[:part]}" if !desc[:part].nil?
    return name
  end

  def name_3gpp
    n  = "%02d%02d" % [spec_serie.index, spec_number]
    n += "-#{spec_part}" if !spec_part.nil?
    n
  end

  def self.find_by_desc(desc)
    name = self.desc_to_name(desc)
    self.find_by_name(name)
  end

  def info_page_url
    "http://www.3gpp.org/ftp/Specs/html-info/#{name_3gpp}.htm"
  end

  def parse_no(spec_no)

    res = Document.parse_no(spec_no)

    self.spec_serie_id = SpecSerie.find_by_index(res[:serie]).id

    self.spec_part = res[:part] if not res[:part].nil?
    self.spec_number = res[:number]

    res
  end
end
