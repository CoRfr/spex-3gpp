class DocumentFile < ActiveRecord::Base
    attr_accessible :format, :sha1, :size

    belongs_to :document_version

    def self.get_filename(doc_version, format)
        name  = "%02d%02d" % [doc_version.document.spec_serie.index, doc_version.document.spec_number]
        name += "-#{doc_version.document.spec_part}" if !doc_version.document.spec_part.nil?
        name += "-#{doc_version.version(:letters)}"
        name += ".#{format}"
    end

    def self.get_local_path(doc_version, format)
        Rails.root.join(
            'specs',
            doc_version.document.spec_serie.index.to_s,
            doc_version.document.name.gsub('.','_'),
            self.get_filename(doc_version, format))
    end

    def local_path
        DocumentFile.get_local_path(document_version, format)
    end

    def analyze
        sha1 = Digest::SHA1.new

        File.open(local_path) do |file|
            buffer = ''

            while not file.eof
                file.read(512, buffer)
                sha1.update(buffer)
            end

            self.size = file.size
            self.sha1 = sha1.to_s
        end
    end

    def content
        File.read( local_path )
    end

end
